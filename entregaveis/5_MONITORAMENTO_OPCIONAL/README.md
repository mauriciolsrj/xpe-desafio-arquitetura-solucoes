# 5. Monitoramento e Observabilidade (OPCIONAL)

## Descrição

Este diretório contém os artefatos opcionais para implementação de monitoramento completo e observabilidade, focado em rastreamento de desempenho, segurança e detecção de falhas.

## Componentes de Monitoramento

### 1. Cloud Monitoring - Coleta de Métricas

**Métricas Coletadas:**

| Métrica | Fonte | Propósito |
|---------|-------|----------|
| CPU Utilization | Ops Agent | Dispara autoscaling |
| Memory Usage | Ops Agent | Detecta vazamento de memória |
| Disk I/O | Ops Agent | Monitora performance |
| Network Traffic | Ops Agent | Rastreia uso de banda |
| Request Latency | Load Balancer | SLI: P99 < 500ms |
| HTTP Status Distribution | Load Balancer | SLI: Error Rate < 1% |
| Database Connections | Cloud SQL | Detecta esgotamento |
| SQL Query Performance | CloudSQL | Monitora queries lentas |

**Arquivo relacionado:** `../../infrastructure/terraform/monitoring.tf`

### 2. Cloud Logging - Coleta de Logs

**Tipos de Logs Coletados:**

```
System Logs:
  /var/log/syslog          - Logs do sistema operacional
  /var/log/auth.log        - Eventos de autenticação
  /var/log/messages        - Mensagens gerais do sistema

Application Logs:
  /var/log/ecommerce/      - Logs da aplicação customizada
  /var/log/nginx/access.log - Requisições HTTP/HTTPS
  /var/log/nginx/error.log  - Erros do servidor web

Cloud Logs:
  Cloud Audit Logs         - Mudanças de infraestrutura
  VPC Flow Logs            - Tráfego de rede
  Cloud SQL Activity Logs  - Operações do banco de dados
```

**Arquivo relacionado:** 
- `../../infrastructure/terraform/monitoring.tf`
- `../../infrastructure/scripts/startup-script.sh`

### 3. Service Level Indicators (SLIs)

**SLI 1: Latência (P99)**

```
Métrica:  Request Latency Percentile 99
Target:   < 500ms
Medida:   compute.googleapis.com/https/request_latencies
Alerta:   Dispara se > 500ms por 5 minutos consecutivos
```

**SLI 2: Taxa de Erro**

```
Métrica:  HTTP 5xx Error Rate
Target:   < 1% (proporção de erros)
Medida:   5xx Status Codes / Total Requests
Alerta:   Dispara se > 1% por 5 minutos consecutivos
```

**Arquivo relacionado:** `../../infrastructure/terraform/monitoring.tf`

### 4. Alertas de Monitoramento

**Alertas Configurados:**

| Alerta | Condição | Ação |
|--------|----------|------|
| P99 Latency High | > 500ms por 5min | Notification Channel |
| Error Rate High | > 1% por 5min | Notification Channel |
| CPU Utilization High | > 80% por 5min | Autoscaling + Notification |
| Memory Usage High | > 85% | Notification Channel |
| Disk Space Low | < 20% disponível | Notification Channel |
| Database Connection Pool | > 150 conexões | Notification Channel |
| SQL Query Slow | > 1000ms | Notification Channel |
| Backup Failed | Erro em backup | Notification Channel |

**Arquivo relacionado:** `../../infrastructure/terraform/monitoring.tf`

### 5. Dashboard Customizado

**Dashboard Principal:**

```
Dashboard: ecommerce-sli-dashboard

Gráficos Inclusos:
  1. MIG Instance Count (série temporal)
  2. CPU Utilization por instância
  3. P99 Latency com threshold
  4. HTTP Status Distribution (2xx, 4xx, 5xx)
  5. Request Rate (RPS)
  6. Database Connection Status
  7. Network Traffic (in/out)
  8. Disk Usage
```

**Arquivo relacionado:** `../../infrastructure/terraform/monitoring.tf`

### 6. Ops Agent - Coleta Automática

**Instalação:**
- Automática via startup script
- Configuração em `/etc/google-cloud-ops-agent/config.yaml`
- Reinicia com a VM

**Funcionalidades:**
- Coleta de métricas do SO (CPU, Memória, Disco, Network)
- Coleta de logs de sistema
- Coleta de logs de aplicação (JSON parsing automático)
- Envio para Cloud Monitoring e Cloud Logging

**Arquivo relacionado:** `../../infrastructure/scripts/startup-script.sh`

## Código Terraform

Todo o código de monitoramento está disponível em:

```
../../infrastructure/terraform/
├── monitoring.tf       # Alertas, Dashboard, SLIs, Uptime Checks
├── outputs.tf          # Outputs para dashboard URLs
└── variables.tf        # Variáveis customizáveis
```

## Configuração de Notificações

Os alertas requerem configuração de canais de notificação.

**Canais Suportados:**
- Email
- Slack
- PagerDuty
- Webhooks HTTP
- SMS

**Arquivo de instrução:** `../../infrastructure/terraform/NOTIFICATIONS.md`

### Exemplo: Configurar Email

```bash
# Via Terraform (em monitoring.tf)
resource "google_monitoring_notification_channel" "email" {
  display_name = "ecommerce-team-email"
  type         = "email"
  
  labels = {
    email_address = "team@example.com"
  }

  enabled = true
}

# Depois, referenciar nos alertas:
notification_channels = [google_monitoring_notification_channel.email.id]
```

### Exemplo: Configurar Slack

```bash
# Via Terraform
resource "google_monitoring_notification_channel" "slack" {
  display_name = "ecommerce-slack"
  type         = "slack"
  
  labels = {
    channel_name = "#alerts"
  }

  enabled = true
}
```

## Como Implementar

```bash
cd ../../infrastructure/terraform

# 1. Preparar variáveis
cp terraform.tfvars.example terraform.tfvars
vim terraform.tfvars

# 2. Inicializar
terraform init

# 3. Aplicar (cria alertas, dashboard, etc)
terraform apply tfplan
```

## Acessar os Dashboards

### Via Google Cloud Console

```bash
# Cloud Monitoring Dashboard
gcloud monitoring dashboards list
gcloud monitoring dashboards describe DASHBOARD_ID

# URL direto no Console
https://console.cloud.google.com/monitoring/dashboards
```

### Via CLI

```bash
# Ver alertas
gcloud alpha monitoring policies list

# Ver métricas em tempo real
gcloud monitoring timeseries list \
  --filter='resource.type="gce_instance"'
```

## Operações Comuns

### Visualizar Logs

```bash
# Logs de sistema
gcloud logging read "severity>=ERROR" --limit=20

# Logs de aplicação
gcloud logging read 'jsonPayload.app="ecommerce"' --limit=20

# Logs de Cloud SQL
gcloud logging read 'resource.type="cloudsql_database"' --limit=20
```

### Visualizar Métricas

```bash
# CPU Utilization
gcloud monitoring timeseries list \
  --filter='metric.type="compute.googleapis.com/instance/cpu/utilization"'

# Memory Usage
gcloud monitoring timeseries list \
  --filter='metric.type="agent.googleapis.com/memory/percent_used"'

# Network Traffic
gcloud monitoring timeseries list \
  --filter='metric.type="compute.googleapis.com/instance/network/received_bytes_count"'
```

### Testar Alertas

```bash
# Listar políticas de alerta
gcloud alpha monitoring policies list

# Ver detalhes de um alerta
gcloud alpha monitoring policies describe POLICY_ID

# Testar notificação
gcloud alpha monitoring channels send-verification-code \
  --notification-channel=CHANNEL_ID
```

## Requisitos de Monitoramento Atendidos

✓ Habilitar logs e monitoramento para desempenho, segurança e falhas  
✓ Cloud Logging para coleta de logs (system, app, cloud)  
✓ Cloud Monitoring para coleta de métricas  
✓ SLIs definido (P99 Latency, Error Rate)  
✓ Alertas configurados para anomalias  
✓ Dashboard customizado com gráficos principais  
✓ Ops Agent instalado em todas as VMs  
✓ Notificações via múltiplos canais  

## Boas Práticas Implementadas

1. **Métricas Significativas:** Apenas métricas que informam decisões
2. **SLIs Realistas:** Baseados em experiência do usuário
3. **Alertas Acionáveis:** Cada alerta tem ação clara
4. **Logs Estruturados:** JSON para parsing automático
5. **Redundância:** Múltiplos canais de notificação
6. **Retention:** Logs retidos conforme política
7. **Cost Optimization:** Apenas dados necessários

## Custo Estimado

- Cloud Monitoring: ~$10-50/mês (depende de métrica volume)
- Cloud Logging: Incluído nos primeiros 50 GB, pago após
- Armazenamento de logs: ~$0.50/GB para retenção além de 30 dias
- Alertas: Grátis (limites generosos)

## Recursos Adicionais

- [Cloud Monitoring Documentation](https://cloud.google.com/monitoring/docs)
- [Cloud Logging Documentation](https://cloud.google.com/logging/docs)
- [Ops Agent Documentation](https://cloud.google.com/stackdriver/docs/agent/google-cloud/ops-agent)
- [Google SRE Book - Monitoring Distributed Systems](https://sre.google/books/)

---

**Autor:** Maurício Santos  
**Data:** Fevereiro 2026
