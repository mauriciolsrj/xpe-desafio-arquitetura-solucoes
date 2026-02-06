# Google Cloud Platform - High Availability E-Commerce Infrastructure

Este diretório contém a Infraestrutura como Código (IaC) completa para uma arquitetura de e-commerce de alta disponibilidade no Google Cloud Platform.

## 📋 Pré-requisitos

- **Google Cloud Project** com billing habilitado
- **Terraform** >= 1.0
- **Google Cloud SDK (gcloud)** instalado e autenticado
- **Credenciais de Serviço** do GCP com as seguintes permissões:
  - `Compute Admin`
  - `Cloud SQL Admin`
  - `Cloud IAM Security Admin`
  - `Service Account Admin`
  - `Cloud Monitoring Admin`

### Instalação de Ferramentas

**macOS (via Homebrew):**
```bash
brew install terraform
brew install --cask google-cloud-sdk
```

**Linux (Ubuntu/Debian):**
```bash
# Terraform
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
unzip terraform_1.6.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/

# Google Cloud SDK
curl https://sdk.cloud.google.com | bash
exec -l $SHELL
gcloud init
```

## 🏗️ Estrutura de Arquivos

```
terraform/
├── main.tf                 # Configuração principal e providers
├── variables.tf            # Declaração de variáveis
├── vpc.tf                  # VPC, Subnets, Firewall Rules
├── compute.tf              # Instance Template, MIG, Autoscaler
├── load-balancer.tf        # Global Load Balancer, Cloud Armor
├── sql.tf                  # Cloud SQL, Replicação, Backups
├── iam.tf                  # Service Accounts, IAM Roles
├── monitoring.tf           # Cloud Monitoring, Alertas, Dashboard
├── outputs.tf              # Outputs
├── terraform.tfvars.example # Exemplo de variáveis
└── terraform.tfvars        # Arquivo de variáveis (não versionar)

scripts/
└── startup-script.sh       # Script de inicialização para VMs

diagrams/
├── logical-architecture.mmd    # Diagrama da arquitetura lógica
└── resilience-flow.mmd         # Diagrama de fluxo de resiliência
```

## 🚀 Deployment Steps

### 1. Configurar Credenciais do GCP

```bash
# Autenticar com sua conta Google
gcloud auth login

# Definir o projeto padrão
gcloud config set project your-gcp-project-id

# Criar arquivo de chave de serviço (recomendado para CI/CD)
gcloud iam service-accounts create terraform-sa \
  --display-name="Terraform Service Account"

gcloud projects add-iam-policy-binding $(gcloud config get-value project) \
  --member="serviceAccount:terraform-sa@$(gcloud config get-value project).iam.gserviceaccount.com" \
  --role="roles/editor"

gcloud iam service-accounts keys create terraform-key.json \
  --iam-account=terraform-sa@$(gcloud config get-value project).iam.gserviceaccount.com

export GOOGLE_APPLICATION_CREDENTIALS="$(pwd)/terraform-key.json"
```

### 2. Preparar Variáveis

```bash
# Copiar arquivo de exemplo
cp terraform.tfvars.example terraform.tfvars

# Editar terraform.tfvars com seus valores
vi terraform.tfvars
```

### 3. Inicializar Terraform

```bash
cd infrastructure/terraform

# Baixar providers e módulos
terraform init

# Validar configuração
terraform validate

# Formatar arquivos (opcional)
terraform fmt -recursive
```

### 4. Revisar Plano

```bash
# Gere um plano de execução
terraform plan -out=tfplan

# Revise os recursos que serão criados
terraform show tfplan
```

### 5. Aplicar Configuração

```bash
# Aplicar as mudanças
terraform apply tfplan

# OU aplicar diretamente (menos seguro)
terraform apply

# Confirmar com 'yes'
```

Este processo levará **aproximadamente 15-20 minutos** devido à criação da Cloud SQL e outras operações longas.

### 6. Verificar Deployment

```bash
# Obter outputs
terraform output -json > deployment-info.json

# Exibir endereço IP do Load Balancer
terraform output load_balancer_ip

# Exibir resumo da implantação
terraform output deployment_summary
```

## 🔑 Outputs Importantes

Após o deployment bem-sucedido, os seguintes outputs estarão disponíveis:

```
load_balancer_ip          # IP externo do Application Load Balancer
https_rule_ip             # IP para acesso HTTPS
mig_name                  # Nome do Managed Instance Group
sql_instance_connection_name  # Connection string para Cloud SQL
service_account_email     # Email da Service Account das VMs
```

## 🛡️ Segurança

### Cloud Armor Rules Habilitadas

- ✅ Proteção contra SQL Injection (SQLi)
- ✅ Proteção contra Cross-Site Scripting (XSS)
- ✅ Proteção contra Protocol Attacks
- ✅ Detecção de Scanner

### Firewall Rules

```
Allow GLB:
  - Source: 130.211.0.0/22, 35.191.0.0/16
  - Ports: 80, 443, 8080
  - Target: http-server, https-server

Allow Internal:
  - Source: 10.0.1.0/24 (VPC CIDR)
  - All Ports

Allow IAP SSH:
  - Source: 35.235.240.0/20
  - Port: 22
```

### IAM Roles para VMs

- `roles/cloudsql.client` - Acesso ao Cloud SQL
- `roles/logging.logWriter` - Envio de logs
- `roles/monitoring.metricWriter` - Envio de métricas

## 📊 Monitoramento e Observabilidade

### Alertas Configurados

**1. P99 Latency Alert**
- Threshold: > 500ms
- Duration: 5 minutos
- Notificação: Configure em `notification_channels`

**2. Error Rate Alert**
- Threshold: > 1% (5xx errors)
- Duration: 5 minutos
- Notificação: Configure em `notification_channels`

### Ops Agent (Instalado via Startup Script)

- **Coleta de Métricas:**
  - CPU Utilization
  - Memory Usage
  - Disk I/O
  - Network Traffic

- **Coleta de Logs:**
  - System logs (/var/log/syslog)
  - Application logs (/var/log/ecommerce/)
  - Nginx access/error logs

### Dashboard Personalizado

Um dashboard foi criado automaticamente com:
- MIG Instance Count
- CPU Utilization
- Request Latency (P99)
- HTTP Status Distribution

Acesse em: **Cloud Console → Monitoring → Dashboards**

## 🗄️ Database Management

### Conexão ao Cloud SQL

#### Via Cloud SQL Proxy

```bash
# Instalar Cloud SQL Proxy
curl -o cloud-sql-proxy https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64
chmod +x cloud-sql-proxy

# Conectar
./cloud-sql-proxy INSTANCE_CONNECTION_NAME
```

#### Via psql (com outro terminal)

```bash
# Obter connection name
CONNECTION_NAME=$(terraform output -raw sql_instance_connection_name)

# Usar Cloud SQL Proxy
psql -h 127.0.0.1 -U app_user -d ecommerce
```

#### Via Secret Manager (Recomendado)

```bash
# Armazenar senha no Secret Manager
echo "YOUR_PASSWORD" | gcloud secrets create db-password --data-file=-

# Recuperar em código
gcloud secrets versions access latest --secret="db-password"
```

### Backups e Recovery

```bash
# Listar backups
gcloud sql backups list --instance=ecommerce-postgres-primary

# Criar backup manual
gcloud sql backups create --instance=ecommerce-postgres-primary

# Restaurar a partir de backup (via Cloud Console recomendado)
```

### Point-in-Time Recovery

Configurado para recuperação até **7 dias** no passado.

```bash
# Exemplo: Restaurar em um ponto específico
gcloud sql backups restore <backup-id> \
  --backup-instance=ecommerce-postgres-primary \
  --target-instance=ecommerce-postgres-restore
```

## ⚙️ Auto Scaling

### Políticas

- **Min Replicas:** 3 instâncias
- **Max Replicas:** 6 instâncias
- **Target CPU:** 70% de utilização
- **Scale-out:** Imediato quando CPU > 70%
- **Scale-in:** 1 instância a cada 10 minutos (controlado)

### Triggers

```bash
# Monitorar atividade de autoscaling
gcloud compute instance-groups managed list

# Ver histórico de scaling
gcloud logging read \
  "resource.type=gce_instance_group_manager AND jsonPayload.event_type=compute.regionAutoscalers.*"
```

## 🌍 Disaster Recovery

### Setup Atual

1. **Primary Database:** us-central1 (Regional HA)
2. **Read Replica:** us-east1 (Cross-region)
3. **Backups:** Armazenados globalmente

### Promover Read Replica

```bash
# Em caso de desastre, promover replica a primary
gcloud sql instances promote-replica ecommerce-postgres-read-replica-dr
```

## 🧹 Cleanup

Para destruir todos os recursos:

```bash
# CUIDADO: Isso removerá todos os recursos!
terraform destroy

# Confirmar com 'yes'

# Remover chaves de serviço
gcloud iam service-accounts delete terraform-sa@$(gcloud config get-value project).iam.gserviceaccount.com
```

## 🐛 Troubleshooting

### Erro: "Permission denied"

```bash
# Verificar permissões
gcloud projects get-iam-policy $(gcloud config get-value project)

# Adicionar role necessária
gcloud projects add-iam-policy-binding $(gcloud config get-value project) \
  --member=user:YOUR_EMAIL \
  --role=roles/compute.admin
```

### MIG Instances não iniciam

```bash
# Verificar logs do startup script
gcloud compute instances describe INSTANCE_NAME \
  --zone=ZONE \
  --format='value(metadata.serializeOutput())'

# Ver serial port output
gcloud compute instances get-serial-port-output INSTANCE_NAME --zone=ZONE
```

### Cloud SQL não conecta

```bash
# Verificar status da instância
gcloud sql instances describe ecommerce-postgres-primary

# Verificar authorize networks
gcloud sql instances describe ecommerce-postgres-primary \
  --format='value(settings.ipConfiguration.authorizedNetworks[])'
```

## 📚 Referências

- [Terraform Google Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [GCP Cloud Armor](https://cloud.google.com/armor/docs)
- [Cloud SQL Best Practices](https://cloud.google.com/sql/docs/postgres/best-practices)
- [Ops Agent Documentation](https://cloud.google.com/stackdriver/docs/agent/google-cloud/ops-agent)

## 💡 Próximos Passos

1. **Integração CI/CD:**
   - Adicionar verificação de Terraform ao GitHub/GitLab
   - Automação de `terraform plan` em PRs

2. **Melhorias de Segurança:**
   - Implementar VPC Service Controls
   - Adicionar BinAuthz para image signing
   - Habilitar VPC Flow Logs

3. **Otimização de Custos:**
   - Avaliar Committed Use Discounts
   - Implementar Budget Alerts
   - Revisar tamanho de máquinas

4. **Aplicação:**
   - Deploy da aplicação ecommerce
   - Configurar CI/CD para application deployments
   - Integração com observabilidade avançada

## 📞 Suporte

Para dúvidas ou problemas:
1. Revisar logs em **Cloud Logging**
2. Verificar status em **Cloud Console**
3. Consultar documentação oficial do GCP
