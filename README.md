# E-Commerce High Availability Architecture - Complete Documentation

## 📑 Overview

Este projeto implementa uma arquitetura de e-commerce totalmente automatizada e altamente disponível no Google Cloud Platform, utilizando Terraform como Infrastructure as Code (IaC).

## 📂 Estrutura do Repositório

```
Pos/
├── infrastructure/
│   ├── terraform/
│   │   ├── main.tf                    # Provider e configurações iniciais
│   │   ├── variables.tf               # Variáveis de entrada
│   │   ├── vpc.tf                     # VPC, Subnets, Firewall
│   │   ├── compute.tf                 # MIG, Instances, Autoscaling
│   │   ├── load-balancer.tf           # Global LB, Cloud Armor
│   │   ├── sql.tf                     # Cloud SQL, Replicação
│   │   ├── iam.tf                     # Service Accounts, Roles
│   │   ├── monitoring.tf              # Monitoring, Alertas, Dashboard
│   │   ├── outputs.tf                 # Outputs
│   │   ├── terraform.tfvars.example   # Exemplo de variáveis
│   │   └── README.md                  # Instruções de deployment
│   └── scripts/
│       └── startup-script.sh          # Script de inicialização das VMs
└── architecture/
    └── diagrams/
        ├── logical-architecture.mmd    # Diagrama da arquitetura
        └── resilience-flow.mmd         # Diagrama de resiliência
```

## 🎯 Componentes da Arquitetura

### 1️⃣ Global External Application Load Balancer
- **Tipo:** HTTP/HTTPS
- **Cloud Armor:** Proteção contra SQLi e XSS
- **Health Checks:** Monitoramento contínuo (path: /health, porta: 8080)
- **Redirect:** HTTP → HTTPS automático

### 2️⃣ Managed Instance Group (Regional)
- **Distribuição:** 3 zonas (us-central1-a, b, c)
- **OS:** Ubuntu 22.04 LTS Minimal
- **Tipo de Máquina:** e2-standard-2 (customizável)
- **Autoscaling:** 3-6 instâncias, trigger baseado em CPU (70%)
- **Health Check:** /health endpoint

### 3️⃣ Cloud SQL - PostgreSQL 15
- **Modo:** Regional HA (Standby automático)
- **Tier:** db-custom-4-16384 (16 vCPU, 16 GB RAM)
- **Armazenamento:** 100 GB SSD com autoresize até 500 GB
- **Backups:** Automáticos diários + PITR (7 dias)
- **Replicação:** Cross-region para DR (us-east1)
- **Connection:** Private Service Connect (sem IP público)

### 4️⃣ Segurança
- **Firewall:** Apenas GLB (130.211.0.0/22, 35.191.0.0/16) pode acessar
- **Service Account:** Roles customizadas (CloudSQL, Logging, Monitoring)
- **Cloud Armor:** Regras OWASP contra SQLi/XSS/DDoS
- **VPC:** Privada com Cloud NAT para acesso externo

### 5️⃣ Monitoramento e Observabilidade
- **Ops Agent:** Instalação automática via startup script
- **Métricas:** CPU, Memória, Disco, Network
- **Logs:** System logs + Application logs
- **Alertas:**
  - P99 Latency > 500ms
  - Error Rate > 1% (5xx)
- **Dashboard:** Customizado com gráficos principais

## 🔧 Como Usar

### Pré-requisitos
```bash
# 1. Google Cloud Project com billing ativo
# 2. Terraform >= 1.0
# 3. Google Cloud SDK instalado
```

### [Ver instruções completas em infrastructure/terraform/README.md](./infrastructure/terraform/README.md)

## 🏛️ Diagramas

### Diagrama de Arquitetura Lógica
Ver: [logical-architecture.mmd](./architecture/diagrams/logical-architecture.mmd)

```
[End Users] 
    ↓ HTTPS
[Global Load Balancer] 
    ↓
[Cloud Armor - SQLi/XSS Protection]
    ↓
[Managed Instance Group]
├── Zone A: Instances
├── Zone B: Instances
└── Zone C: Instances
    ↓ Private Service Connect
[Cloud SQL Primary - HA]
    ↌ Async Replication
[Cloud SQL Replica - DR (us-east1)]
```

### Diagrama de Fluxo de Resiliência
Ver: [resilience-flow.mmd](./architecture/diagrams/resilience-flow.mmd)

Mostra como o sistema se comporta durante:
- Falha de zona de disponibilidade
- Disparo de autoscaling
- Failover automático do banco de dados
- Recuperação e rebalanceamento

## 📊 Service Level Indicators (SLIs)

### Latência (P99)
- **Target:** < 500ms
- **Medida:** Request latency percentile 99
- **Alert:** Dispara se > 500ms por 5 minutos

### Taxa de Erro
- **Target:** < 1%
- **Medida:** Número de respostas 5xx / total de requests
- **Alert:** Dispara se > 1% por 5 minutos

## 🚀 Deployment

1. **Clonar repositório e acessar pasta terraform:**
   ```bash
   cd infrastructure/terraform
   ```

2. **Copiar e editar variáveis:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   vim terraform.tfvars
   ```

3. **Inicializar Terraform:**
   ```bash
   terraform init
   ```

4. **Validar e fazer plano:**
   ```bash
   terraform plan -out=tfplan
   ```

5. **Aplicar configuração:**
   ```bash
   terraform apply tfplan
   ```

⏱️ **Tempo estimado:** 15-20 minutos

## 📈 Autoscaling

### Funcionamento
```
CPU Utilization
    ↓
    70% (target)
    ↓
[Autoscaler Decision]
    ├── CPU > 70% → Scale Up (máx 1 nova instância)
    └── CPU < 70% → Scale Down (máx 1 instância a cada 10 min)
    ↓
[Update MIG]
    ↓
[New Instances Start]
    ↓
[Health Check Pass]
    ↓
[Join Load Balancer]
```

## 🔒 Cloud Armor Rules

| Regra | Tipo | Ação |
|-------|------|------|
| 1 | SQL Injection | Deny (403) |
| 2 | SQL Injection (Preconfigured) | Deny (403) |
| 3 | XSS | Deny (403) |
| 4+ | OWASP (Protocol, Scanner) | Deny (403) |
| Default | Allow | Allow (200) |

## 🗄️ Database

### Backup e Recovery

**Politica de Backups:**
- Automático: Diariamente às 3:00 AM UTC
- Retenção: 30 snapshots
- PITR: Até 7 dias no passado
- Cross-region: Read replica em us-east1

**Recuperação:**
```bash
# Simples: Via Cloud Console
# Avançado: Usando Cloud SQL Admin API
```

## 📝 Customizações Comuns

### 1. Mudar Número de Instâncias
```hcl
# Em terraform.tfvars
min_instances = 5
max_instances = 10
```

### 2. Adicionar Novo Firewall Rule
```hcl
# Em vpc.tf
resource "google_compute_firewall" "custom" {
  name = "custom-rule"
  # ...
}
```

### 3. Alterar Tipo de Máquina
```hcl
# Em terraform.tfvars
machine_type = "e2-standard-4"
```

### 4. Adicionar Notification Channel
```hcl
# Em monitoring.tf
notification_channels = [
  google_monitoring_notification_channel.email.id
]
```

## 🐛 Troubleshooting

### Startup Script Não Executa
```bash
# Verificar serial port
gcloud compute instances get-serial-port-output INSTANCE \
  --zone=ZONE
```

### MIG Instances Não Saudáveis
```bash
# Verificar health check
gcloud compute backend-services get-health BACKEND_SERVICE \
  --global
```

### Cloud SQL Não Conecta
```bash
# Verificar Private Service Connection
gcloud sql instances describe INSTANCE \
  --format='value(settings.ipConfiguration)'
```

## 🔐 Segurança

### Checklist de Segurança
- [ ] Firewall rules restringem acesso apenas ao GLB
- [ ] Service Account tem mínimas permissões necessárias
- [ ] Cloud Armor policies habilitadas
- [ ] SSL/TLS certificado válido
- [ ] Database credentials armazenados em Secret Manager
- [ ] VPC Flow Logs habilitado
- [ ] Cloud Audit Logs habilitado

## 💰 Estimativa de Custos

**Componentes:**
- Compute (MIG): ~$150/mês (3-6 instâncias)
- Cloud SQL: ~$200/mês (Custom tier)
- Load Balancer: ~$35/mês
- Network: ~$50/mês
- Monitoring: $10-50/mês

**Total Estimado:** ~$445-495/mês (US$)

*Nota: Checar Google Cloud Pricing Calculator para valores precisos*

## 📚 Recursos Adicionais

- [Terraform Google Provider Docs](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [GCP Architecture Best Practices](https://cloud.google.com/architecture)
- [Cloud Armor Documentation](https://cloud.google.com/armor/docs)
- [Cloud SQL Best Practices](https://cloud.google.com/sql/docs/postgres/best-practices)

## 📞 Suporte

Em caso de dúvidas:
1. Verifique logs em Cloud Logging
2. Consulte documentação do GCP
3. Verifique alertas em Cloud Monitoring
4. Revise terraform state

## ✅ Checklist de Implementação

- [ ] Variáveis configuradas (terraform.tfvars)
- [ ] Terraform init executado
- [ ] Plan revisado e aprovado
- [ ] Apply executado com sucesso
- [ ] Outputs verificados
- [ ] Health checks passando
- [ ] Alertas configurados
- [ ] Backups testados
- [ ] Failover testado
- [ ] Documentação atualizada

---

**Versão:** 1.0  
**Última Atualização:** Fevereiro 2026  
**Mantido por:** Arquiteto de Soluções GCP