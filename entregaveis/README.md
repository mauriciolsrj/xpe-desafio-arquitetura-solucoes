# ENTREGÁVEIS - DESAFIO FINAL BOOTCAMP ARQUITETO DE SOLUÇÕES

## Bem-vindo

Este diretório contém todos os artefatos solicitados para o **Desafio Final do Bootcamp Arquiteto de Soluções**.

Todos os requisitos obrigatórios foram atendidos e os requisitos opcionais foram implementados completamente.

---

## Estrutura de Pastas

```
entregaveis/
├── 1_DIAGRAMA_ARQUITETURA_OBRIGATORIO/        ← OBRIGATÓRIO
│   ├── README.md                               Demonstração do diagrama
│   └── logica-arquitetura.drawio               Diagrama em Draw.io (abrir em draw.io)
│
├── 2_INFRAESTRUTURA_IAAS_OPCIONAL/             ← OPCIONAL (Implementado)
│   └── README.md                               Explicação do provisionamento IaaS
│
├── 3_INFRAESTRUTURA_PAAS_OPCIONAL/             ← OPCIONAL (Implementado)
│   └── README.md                               Explicação do provisionamento PaaS
│
├── 4_SEGURANCA_IAMOPCIONAL/                    ← OPCIONAL (Implementado)
│   └── README.md                               Explicação da segurança e IAM
│
├── 5_MONITORAMENTO_OPCIONAL/                   ← OPCIONAL (Implementado)
│   └── README.md                               Explicação de logs e monitoramento
│
├── VERIFICACAO_REQUISITOS.md                   Matriz de atendimento de requisitos
└── README.md                                   Este arquivo
```

---

## Quick Start

### 1. O que é OBRIGATÓRIO?

**Diagrama da Arquitetura (Pasta 1)**

Arquivo: `1_DIAGRAMA_ARQUITETURA_OBRIGATORIO/logica-arquitetura.drawio`

Como abrir:
1. Acesse [draw.io](https://draw.io)
2. Clique em "File" > "Open"
3. Selecione o arquivo `logica-arquitetura.drawio`

O diagrama contém:
- ✅ Múltiplas zonas de disponibilidade (A, B, C)
- ✅ Balanceador de carga global (GLB)
- ✅ Instâncias em autoscaling (3-6)
- ✅ Banco de dados gerenciado (Cloud SQL)
- ✅ IAM e controle de acesso
- ✅ Failover e mecanismos de resiliência

### 2. O que é OPCIONAL mas foi Implementado?

Todas as pastas 2, 3, 4 e 5 contêm:
- **READMEs explicativos** com detalhes de cada componente
- **Referências ao código Terraform** que provisiona cada recurso
- **Instruções de uso** e operação
- **Comandos gcloud** para verificar configurações

---

## Verificação Rápida de Requisitos

Execute para ver matriz completa de requisitos:

```bash
cat VERIFICACAO_REQUISITOS.md
```

Resumo:
| Requisito | Obrigatório | Status |
|-----------|------------|--------|
| Múltiplas zonas | SIM | ✅ |
| Load Balancer | SIM | ✅ |
| Autoscaling | SIM | ✅ |
| Banco PaaS | SIM | ✅ |
| IAM | SIM | ✅ |
| IaaS Completo | NÃO | ✅ |
| PaaS Completo | NÃO | ✅ |
| Segurança | NÃO | ✅ |
| Monitoramento | NÃO | ✅ |

---

## Acessar o Código Terraform

Todos os arquivos de implementação estão em:

```
../infrastructure/terraform/
├── main.tf              Providers e APIs
├── variables.tf         Variáveis customizáveis
├── vpc.tf               Rede e firewall
├── compute.tf           VMs e MIG
├── load-balancer.tf     Load Balancer e Cloud Armor
├── sql.tf               Banco de dados + HA + DR
├── iam.tf               Service Accounts e Roles
├── monitoring.tf        Alertas, SLIs, Dashboard
├── outputs.tf           Outputs do deployment
├── terraform.tfvars.example    Exemplo de configuração
├── README.md            Guia passo-a-passo
└── NOTIFICATIONS.md     Configuração de alertas
```

---

## Onde Está o Quê

### Diagrama da Arquitetura
**Pasta:** `1_DIAGRAMA_ARQUITETURA_OBRIGATORIO/`
- Arquivo: `logica-arquitetura.drawio`
- Abrir em: [draw.io](https://draw.io)

### Provisionamento IaaS (VMs, LB)
**Pasta:** `2_INFRAESTRUTURA_IAAS_OPCIONAL/`
- README: Descrição dos componentes
- Código: `../infrastructure/terraform/compute.tf`
- Script: `../infrastructure/scripts/startup-script.sh`

### Provisionamento PaaS (Banco de Dados)
**Pasta:** `3_INFRAESTRUTURA_PAAS_OPCIONAL/`
- README: Descrição do banco
- Código: `../infrastructure/terraform/sql.tf`

### Segurança e IAM
**Pasta:** `4_SEGURANCA_IAMOPCIONAL/`
- README: Políticas de segurança
- Código: `../infrastructure/terraform/iam.tf`

### Monitoramento
**Pasta:** `5_MONITORAMENTO_OPCIONAL/`
- README: Logs e métricas
- Código: `../infrastructure/terraform/monitoring.tf`

---

## Componentes da Arquitetura

### Diagrama Visual

```
                          End Users
                              ↓
                        Global Load Balancer
                        (HTTP/HTTPS)
                              ↓
                        Cloud Armor
                     (SQLi/XSS Protection)
                              ↓
        ┌─────────────────────┼─────────────────────┐
        ↓                      ↓                      ↓
    Zone A                 Zone B                 Zone C
  Instances              Instances             Instances
  (Ubuntu LTS)           (Ubuntu LTS)          (Ubuntu LTS)
  
        └─────────────────────┼─────────────────────┘
                              ↓
                    Private Service Connect
                              ↓
                        Cloud SQL Primary
                      (PostgreSQL 15, Regional HA)
                              ↓
                    Cloud SQL Replica
                    (us-east1, DR)
```

### Escalabilidade

```
Min: 3 instâncias ─→ CPU > 70% ─→ Scale-up (máx 1/vez) ─→ Max: 6 instâncias
                                                               ↓
                                                        CPU < 70%
                                                               ↓
                                             Scale-down (máx 1/10min)
```

### Alta Disponibilidade

```
Zona A falha ─→ Health Check detecta ─→ Traffic redireciona para B+C
            ─→ Autoscaler dispara ─→ Novas instâncias em B+C
            ─→ Volta ao min (3) ─→ Zona A se recupera ─→ Rebalanceia
```

### Disaster Recovery

```
Primary DB falha ─→ Failover automático (segundos) ─→ Standby vira Primary
Regional DR ─→ Manual: Promove read-replica se necessário
Backups ─→ PITR até 7 dias ou snapshot específico
```

---

## Requisitos Atendidos

### Obrigatórios (Todos ✅)

```
1. Desenho da Arquitetura
   ├─ Múltiplas zonas de disponibilidade ✅
   ├─ Balanceamento de carga ✅
   ├─ Escalonamento automático (3-6, Linux) ✅
   ├─ Banco de dados gerenciado (PaaS) ✅
   └─ IAM para acesso ao banco ✅
```

### Opcionais (Todos ✅)

```
2. Provisionamento IaaS
   ├─ VMs em múltiplas zonas ✅
   ├─ Load Balancer ✅
   ├─ Autoscaling (3-6 instâncias) ✅
   ├─ Firewall seguro ✅
   └─ Startup script automatizado ✅

3. Provisionamento PaaS
   ├─ Cloud SQL ✅
   ├─ Alta Disponibilidade regional ✅
   ├─ Replicação cross-region ✅
   ├─ Backups e PITR ✅
   └─ IAM Roles ✅

4. Segurança
   ├─ Políticas de IAM ✅
   ├─ Cloud Armor ✅
   ├─ Firewall rules ✅
   ├─ VPC privada ✅
   └─ Private Service Connection ✅

5. Monitoramento
   ├─ Cloud Logging ✅
   ├─ Cloud Monitoring ✅
   ├─ SLIs (P99 Latency, Error Rate) ✅
   ├─ Alertas configurados ✅
   ├─ Ops Agent ✅
   └─ Dashboard customizado ✅
```

---

## Como Usar Este Repositório

### Para Apresentação do Diagrama
1. Abra `1_DIAGRAMA_ARQUITETURA_OBRIGATORIO/logica-arquitetura.drawio` no Draw.io
2. Leia `1_DIAGRAMA_ARQUITETURA_OBRIGATORIO/README.md`
3. Mostre o diagrama interativo no Draw.io

### Para Explicar Implementação
1. Leia `2_INFRAESTRUTURA_IAAS_OPCIONAL/README.md`
2. Leia `3_INFRAESTRUTURA_PAAS_OPCIONAL/README.md`
3. Leia `4_SEGURANCA_IAMOPCIONAL/README.md`
4. Leia `5_MONITORAMENTO_OPCIONAL/README.md`
5. Referendar aos arquivos Terraform correspondentes

### Para Verificação de Requisitos
1. Abra `VERIFICACAO_REQUISITOS.md`
2. Veja matriz completa de atendimento
3. Confirme que todos os requisitos estão "✅"

---

## Informações Adicionais

### Tecnologia Utilizada
- **Cloud:** Google Cloud Platform (GCP)
- **IaC:** Terraform
- **Database:** PostgreSQL 15 (Cloud SQL)
- **Compute:** Ubuntu 22.04 LTS
- **Monitoring:** Cloud Logging + Cloud Monitoring
- **Diagram:** Draw.io

### Arquitetura Implementa
- **Padrão:** Multi-zone High Availability
- **Resiliência:** 99.95% SLA
- **Escalabilidade:** 3-6 instâncias automáticas
- **Segurança:** Defense in Depth
- **Recovery:** DR com PITR

### Custo Estimado (AWS Equivalente)
- Compute (3-6 VMs): ~$150/mês
- Banco de Dados: ~$200/mês
- Load Balancer: ~$35/mês
- Networking: ~$50/mês
- Monitoring: ~$10-50/mês
- **Total: ~$445-495/mês**

---

## Próximos Passos

1. **Apresentar o Diagrama:** Abra em Draw.io e explique componentes
2. **Deploy da Arquitetura:** Siga guia em `infrastructure/terraform/README.md`
3. **Testar Funcionalidades:** Script de testes em `infrastructure/OPERATIONS.md`
4. **Configurar Notificações:** Siga `infrastructure/terraform/NOTIFICATIONS.md`
5. **Monitorar:** Visualize dashboards em `5_MONITORAMENTO_OPCIONAL/README.md`

---

## Documentação Complementar

- **Diagrama Detalhado:** `1_DIAGRAMA_ARQUITETURA_OBRIGATORIO/README.md`
- **IaaS Implementation:** `2_INFRAESTRUTURA_IAAS_OPCIONAL/README.md`
- **PaaS Implementation:** `3_INFRAESTRUTURA_PAAS_OPCIONAL/README.md`
- **Security Details:** `4_SEGURANCA_IAMOPCIONAL/README.md`
- **Monitoring Setup:** `5_MONITORAMENTO_OPCIONAL/README.md`
- **Requisitos Check:** `VERIFICACAO_REQUISITOS.md`

---

**Autor:** Maurício Santos  
**Bootcamp:** Arquiteto de Soluções  
**Desafio:** Desafio Final  
**Status:** ✅ Completamente Implementado  
**Data:** Fevereiro 2026
