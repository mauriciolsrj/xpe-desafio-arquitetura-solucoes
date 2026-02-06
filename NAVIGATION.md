# 🗺️ Mapa de Navegação do Repositório

## 📍 Índice Rápido

### 🚀 Comece Aqui
- **[README.md](./README.md)** - Overview da arquitetura completa
- **[IMPLEMENTATION_SUMMARY.md](./IMPLEMENTATION_SUMMARY.md)** - Resumo dos artefatos entregues

### 🏗️ Infraestrutura (Terraform)
**Localização:** `infrastructure/terraform/`

#### 📚 Documentação
- **[README.md](./infrastructure/terraform/README.md)** - **👈 LEIA PRIMEIRO!** Passo a passo completo de deployment
- **[NOTIFICATIONS.md](./infrastructure/terraform/NOTIFICATIONS.md)** - Como configurar canais de alertas

#### 📝 Código Terraform (em ordem de dependência)
1. **[main.tf](./infrastructure/terraform/main.tf)** - Configuração de providers e APIs
2. **[variables.tf](./infrastructure/terraform/variables.tf)** - Declaração de variáveis
3. **[vpc.tf](./infrastructure/terraform/vpc.tf)** - VPC, Subnets, Firewall
4. **[compute.tf](./infrastructure/terraform/compute.tf)** - MIG, Instances, Autoscaler
5. **[load-balancer.tf](./infrastructure/terraform/load-balancer.tf)** - Global LB + Cloud Armor
6. **[sql.tf](./infrastructure/terraform/sql.tf)** - Cloud SQL com HA + DR
7. **[iam.tf](./infrastructure/terraform/iam.tf)** - Service Accounts + Roles
8. **[monitoring.tf](./infrastructure/terraform/monitoring.tf)** - Alertas, Dashboard, SLIs
9. **[outputs.tf](./infrastructure/terraform/outputs.tf)** - Outputs

#### 🔧 Configuração
- **[terraform.tfvars.example](./infrastructure/terraform/terraform.tfvars.example)** - Copiar para `terraform.tfvars` e customizar

### 📜 Scripts
**Localização:** `infrastructure/scripts/`

- **[startup-script.sh](./infrastructure/scripts/startup-script.sh)** - Instalação do Ops Agent, Nginx, Node.js

### 🎨 Diagramas (Mermaid.js)
**Localização:** `architecture/diagrams/`

- **[logical-architecture.mmd](./architecture/diagrams/logical-architecture.mmd)** - Arquitetura lógica completa
- **[resilience-flow.mmd](./architecture/diagrams/resilience-flow.mmd)** - Fluxo de resiliência e failover

### 📖 Operação
**Localização:** `infrastructure/`

- **[OPERATIONS.md](./infrastructure/OPERATIONS.md)** - Procedimentos de operação, troubleshooting e manutenção

---

## 🎯 Guias por Persona

### 👨‍💻 Desenvolvedor (Quer entender a arquitetura)
1. Leia [README.md](./README.md)
2. Visualize [logical-architecture.mmd](./architecture/diagrams/logical-architecture.mmd)
3. Explore [startup-script.sh](./infrastructure/scripts/startup-script.sh)
4. Veja [IMPLEMENTATION_SUMMARY.md](./IMPLEMENTATION_SUMMARY.md)

### 🏗️ Arquiteto (Quer conhecer a infraestrutura)
1. Leia [IMPLEMENTATION_SUMMARY.md](./IMPLEMENTATION_SUMMARY.md)
2. Revise [main.tf](./infrastructure/terraform/main.tf) até [sql.tf](./infrastructure/terraform/sql.tf)
3. Analise os diagramas Mermaid em `architecture/diagrams/`
4. Revise [OPERATIONS.md](./infrastructure/OPERATIONS.md) para production readiness

### 🔧 DevOps/SRE (Quer fazer o deploy)
1. Siga [infrastructure/terraform/README.md](./infrastructure/terraform/README.md) passo a passo
2. Configure [terraform.tfvars.example](./infrastructure/terraform/terraform.tfvars.example)
3. Execute os comandos Terraform (init → plan → apply)
4. Use [OPERATIONS.md](./infrastructure/OPERATIONS.md) para operação diária

### 🚨 On-Call (Quer resolver problemas)
1. Acesse [infrastructure/OPERATIONS.md#troubleshooting](./infrastructure/OPERATIONS.md)
2. Use seção apropriada (MIG, Database, Load Balancer, Notifications)
3. Consulte logs em [infrastructure/terraform/README.md#verificar-deployment](./infrastructure/terraform/README.md)

### 📊 SRE/Observability (Quer configurar monitoramento)
1. Leia [infrastructure/terraform/NOTIFICATIONS.md](./infrastructure/terraform/NOTIFICATIONS.md)
2. Revise [monitoring.tf](./infrastructure/terraform/monitoring.tf)
3. Configure canais de notificação (Email, Slack, PagerDuty)
4. Visualize dashboard em Cloud Console → Monitoring

---

## 📋 Checklist de Tarefas

### Antes do Deploy
- [ ] Repositório clonado
- [ ] Leitura de `infrastructure/terraform/README.md`
- [ ] GCP Project criado com billing
- [ ] Terraform instalado e testado
- [ ] `terraform.tfvars.example` copiado para `terraform.tfvars`
- [ ] Valores customizados em `terraform.tfvars`

### Durante o Deploy
- [ ] `terraform init` executado com sucesso
- [ ] `terraform validate` passou
- [ ] `terraform plan` revisado
- [ ] `terraform apply` completado (~15-20 minutos)
- [ ] Outputs obtidos com `terraform output -json`

### Depois do Deploy
- [ ] Health checks passando (`gcloud compute backend-services get-health`)
- [ ] Load Balancer respondendo (testar IP do output)
- [ ] MIG instâncias saudáveis
- [ ] Cloud SQL conectando
- [ ] Ops Agent coletando métricas
- [ ] Alertas configurados (seguir [NOTIFICATIONS.md](./infrastructure/terraform/NOTIFICATIONS.md))
- [ ] Dashboard customizado funcionando

### Operação Contínua
- [ ] Monitorar SLIs (P99 Latency, Error Rate)
- [ ] Revisar logs em Cloud Logging
- [ ] Testar failover mensal
- [ ] Validar backups
- [ ] Revisar custos
- [ ] Atualizar documentação conforme necessário

---

## 🔍 Encontrar Informações

### "Como fazer deployment?"
→ [infrastructure/terraform/README.md](./infrastructure/terraform/README.md)

### "Qual é a arquitetura?"
→ [README.md](./README.md) + Diagramas em `architecture/diagrams/`

### "Como configurar alertas?"
→ [infrastructure/terraform/NOTIFICATIONS.md](./infrastructure/terraform/NOTIFICATIONS.md)

### "Minha aplicação não está respondendo!"
→ [infrastructure/OPERATIONS.md#troubleshooting](./infrastructure/OPERATIONS.md)

### "Como escalar a infraestrutura?"
→ [infrastructure/OPERATIONS.md#capacity-planning](./infrastructure/OPERATIONS.md)

### "Quais são os componentes?"
→ [IMPLEMENTATION_SUMMARY.md](./IMPLEMENTATION_SUMMARY.md)

### "Como conectar ao banco de dados?"
→ [infrastructure/terraform/README.md#database-management](./infrastructure/terraform/README.md)

### "Como fazer backup/restore?"
→ [infrastructure/OPERATIONS.md#backup-and-recovery](./infrastructure/OPERATIONS.md)

---

## 📁 Estrutura Completa

```
Pos/
├── README.md                          ← START HERE!
├── IMPLEMENTATION_SUMMARY.md          ← Resumo dos artefatos
│
├── infrastructure/
│   ├── OPERATIONS.md                  ← Operação e troubleshooting
│   │
│   ├── terraform/                     ← Código Infrastructure as Code
│   │   ├── main.tf                    ← Providers e APIs
│   │   ├── variables.tf               ← Variáveis
│   │   ├── vpc.tf                     ← VPC e Firewall
│   │   ├── compute.tf                 ← MIG e Autoscaler
│   │   ├── load-balancer.tf           ← Global LB + Cloud Armor
│   │   ├── sql.tf                     ← Cloud SQL HA + DR
│   │   ├── iam.tf                     ← Service Accounts + Roles
│   │   ├── monitoring.tf              ← Alertas e SLIs
│   │   ├── outputs.tf                 ← Outputs
│   │   ├── terraform.tfvars.example   ← Config de exemplo
│   │   ├── README.md                  ← Deployment step-by-step
│   │   └── NOTIFICATIONS.md           ← Setup de alertas
│   │
│   └── scripts/
│       └── startup-script.sh          ← Ops Agent + configuração
│
└── architecture/
    └── diagrams/
        ├── logical-architecture.mmd   ← Diagrama da arquitetura
        └── resilience-flow.mmd        ← Cenários de falha/recuperação
```

---

## 🎓 Leitura Recomendada (por ordem)

1. **Para Não-Técnicos:** README.md + IMPLEMENTATION_SUMMARY.md
2. **Para Técnicos/Arquitetos:** README.md → Diagramas → IMPLEMENTATION_SUMMARY.md
3. **Para Deployar:** infrastructure/terraform/README.md → terraform.tfvars → terraform commands
4. **Para Operar:** infrastructure/OPERATIONS.md → infrastruc/terraform/NOTIFICATIONS.md
5. **Para Entender Segurança:** vpc.tf, iam.tf, load-balancer.tf (Cloud Armor section), sql.tf

---

## 🆘 Precisa de Ajuda?

| Situação | Arquivo |
|----------|---------|
| "Não sei por onde começar" | [README.md](./README.md) |
| "Quero fazer o deploy" | [infrastructure/terraform/README.md](./infrastructure/terraform/README.md) |
| "Tenho um erro para resolver" | [infrastructure/OPERATIONS.md](./infrastructure/OPERATIONS.md) |
| "Preciso configurar alertas" | [infrastructure/terraform/NOTIFICATIONS.md](./infrastructure/terraform/NOTIFICATIONS.md) |
| "Quero entender os componentes" | [IMPLEMENTATION_SUMMARY.md](./IMPLEMENTATION_SUMMARY.md) |
| "Preciso visualizar a arquitetura" | [architecture/diagrams/](./architecture/diagrams/) |

---

## 📞 Contato/Suporte

Para dúvidas sobre:
- **Terraform**: Consulte [Terraform Google Provider Docs](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- **GCP Services**: Consulte [Google Cloud Documentation](https://cloud.google.com/docs)
- **Alertas/Monitoring**: Veja [infrastructure/terraform/NOTIFICATIONS.md](./infrastructure/terraform/NOTIFICATIONS.md)
- **Operação**: Leia [infrastructure/OPERATIONS.md](./infrastructure/OPERATIONS.md)

---

**Última atualização:** Fevereiro 2026  
**Versão:** 1.0  
**Status:** Production Ready ✅
