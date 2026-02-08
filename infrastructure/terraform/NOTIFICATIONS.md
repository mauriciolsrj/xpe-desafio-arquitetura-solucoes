# Notification Channels Configuration Guide

## Configurando Canais de Notificação para Alertas

Os alertas definidos em `monitoring.tf` requerem configuração de canais de notificação (notification channels) para funcionar. Siga as instruções abaixo.

## Canais Suportados

- **Email**
- **Slack**
- **PagerDuty**
- **Webhooks HTTP**
- **SMS (em regiões selecionadas)**

## 1. Via Cloud Console (Mais Fácil)

### Passo 1: Acessar Cloud Monitoring

```
Google Cloud Console 
  → Monitoring 
  → Alerting 
  → Notification Channels
```

### Passo 2: Criar Novo Canal

**Para Email:**
1. Clique em **"Create Channel"**
2. Selecione **"Email"**
3. Insira seu email ou distribuição de grupo
4. Clique em **"Create Channel"**

**Para Slack:**
1. Clique em **"Create Channel"**
2. Selecione **"Slack"**
3. Autorize o Google Cloud a acessar seu Slack workspace
4. Selecione o canal desejado
5. Clique em **"Create Channel"**

### Passo 3: Copiar ID do Canal

Cada canal criado terá um ID similar a:
```
projects/seu-projeto/notificationChannels/123456789
```

## 2. Via Terraform (Recomendado para IaC)

Adicione este bloco ao arquivo `monitoring.tf`:

```hcl
# Email Notification Channel
resource "google_monitoring_notification_channel" "email" {
  display_name = "ecommerce-team-email"
  type         = "email"
  
  labels = {
    email_address = "seu-email@example.com"  # MUDAR para seu email
  }

  enabled = true
}

# Slack Notification Channel
resource "google_monitoring_notification_channel" "slack" {
  display_name = "ecommerce-team-slack"
  type         = "slack"
  
  labels = {
    channel_name = "#alerts"  # MUDAR para seu canal Slack
  }

  enabled = true
}

# PagerDuty Notification Channel (opcional)
resource "google_monitoring_notification_channel" "pagerduty" {
  display_name = "pagerduty-integration"
  type         = "pagerduty"
  
  labels = {
    service_key = var.pagerduty_service_key  # Definir em variables.tf
  }

  enabled = true
}
```

### Adicionar variáveis em `variables.tf`:

```hcl
variable "notification_email" {
  description = "Email for notifications"
  type        = string
  default     = "seu-email@example.com"
}

variable "slack_channel" {
  description = "Slack channel name"
  type        = string
  default     = "#alerts"
}

variable "pagerduty_service_key" {
  description = "PagerDuty service key"
  type        = string
  sensitive   = true
  default     = ""  # Definir via terraform.tfvars
}
```

### Adicionar em `terraform.tfvars`:

```hcl
notification_email = "seu-email@company.com"
slack_channel      = "#oncall"
pagerduty_service_key = "seu-pagerduty-key"  # Se usar PagerDuty
```

### Atualizar Alertas para Usar Canais

Modifique as políticas de alerta em `monitoring.tf`:

```hcl
resource "google_monitoring_alert_policy" "latency_p99" {
  # ... resto da configuração ...

  notification_channels = [google_monitoring_notification_channel.email.id]
}

resource "google_monitoring_alert_policy" "error_rate" {
  # ... resto da configuração ...

  notification_channels = [google_monitoring_notification_channel.slack.id]
}
```

## 3. Testando Notificações

### Via gcloud CLI

```bash
# Listar canais de notificação
gcloud alpha monitoring channels list

# Testar canal de email
gcloud alpha monitoring channels send-verification-code \
  --notification-channel=projects/PROJECT_ID/notificationChannels/CHANNEL_ID
```

### Via Cloud Console

1. Vá em **Alerting → Notification Channels**
2. Selecione seu canal
3. Clique em **"Edit"**
4. Clique em **"Test Notification"**

## 4️⃣ SLI Alerting Best Practices

### P99 Latency Alert

```hcl
resource "google_monitoring_alert_policy" "latency_p99" {
  project      = var.project_id
  display_name = "${var.app_name} - P99 Latency (> 500ms)"
  combiner     = "OR"

  conditions {
    display_name = "P99 Latency exceeds 500ms"

    condition_threshold {
      filter          = "resource.type=\"global\" AND metric.type=\"compute.googleapis.com/https/request_latencies\""
      duration        = "300s"        # 5 minutos
      comparison      = "COMPARISON_GT"
      threshold_value = 500000        # 500ms em microsegundos

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_PERCENTILE_99"
      }

      trigger_count {
        count   = 1
        percent = 0
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.email.id]
}
```

### Error Rate Alert

```hcl
resource "google_monitoring_alert_policy" "error_rate" {
  project      = var.project_id
  display_name = "${var.app_name} - Error Rate (> 1%)"
  combiner     = "OR"

  conditions {
    display_name = "Error rate exceeds 1%"

    condition_threshold {
      filter          = "resource.type=\"global\" AND metric.type=\"compute.googleapis.com/https/request_count\" AND metric.response_code_class=\"5xx\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0.01         # 1%

      aggregations {
        alignment_period       = "60s"
        per_series_aligner     = "ALIGN_RATE"
        cross_series_reducer   = "REDUCE_SUM"
        group_by_fields = [
          "resource.type",
          "metric.response_code_class"
        ]
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.slack.id]
}
```

## 5️⃣ Slack Webhook Customization

Para integração mais avançada com Slack, use webhooks:

```bash
# 1. Em seu workspace Slack, criar uma app
# 2. Adicionar Incoming Webhooks e copiar URL

# 3. No Terraform:
resource "google_monitoring_notification_channel" "slack_webhook" {
  display_name = "slack-webhook"
  type         = "webhook_tokenauth"
  
  labels = {
    url = "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
  }

  enabled = true
}
```

## 6️⃣ Escalação (Escalation Policy)

Configurar múltiplos canais para diferentes severidades:

```hcl
# Alerta P99 → Email
notification_channels = [
  google_monitoring_notification_channel.email.id
]

# Alerta Crítico → Email + Slack + PagerDuty
notification_channels = [
  google_monitoring_notification_channel.email.id,
  google_monitoring_notification_channel.slack.id,
  google_monitoring_notification_channel.pagerduty.id
]
```

## 7️⃣ Verificação

### Listar canais e alertas:

```bash
# Verificar se notificação foi enviada
gcloud logging read \
  "resource.type=global AND protoPayload.methodName=monitoring.alertPolicies.create" \
  --limit=10

# Ver status dos canais
gcloud alpha monitoring channels list --format=json | jq '.[] | select(.displayName=="seu-canal")'
```

## Exemplo Completo (terraform.tfvars)

```hcl
project_id = "seu-projeto"
primary_region = "us-central1"
notification_email = "alerts@company.com"
slack_channel = "#prod-alerts"
```

## Alertas Recomendados Adicionais

Além dos 2 alertas principais, considere adicionar:

```hcl
# 1. CPU Alta
resource "google_monitoring_alert_policy" "cpu_high" {
  display_name = "High CPU Usage"
  # ...
}

# 2. Memória Alta
resource "google_monitoring_alert_policy" "memory_high" {
  display_name = "High Memory Usage"
  # ...
}

# 3. Disco Cheio
resource "google_monitoring_alert_policy" "disk_full" {
  display_name = "Disk Usage High"
  # ...
}

# 4. Replicação SQL Atrasada
resource "google_monitoring_alert_policy" "sql_replica_lag" {
  display_name = "SQL Replication Lag"
  # ...
}

# 5. MIG Scale Events
resource "google_monitoring_alert_policy" "mig_scaling_issues" {
  display_name = "MIG Scaling Issues"
  # ...
}
```

## Troubleshooting

### Notificações não chegando

```bash
# 1. Verificar canal
gcloud alpha monitoring channels describe CHANNEL_ID

# 2. Verificar alertas
gcloud alpha monitoring policies list

# 3. Ver logs de tentativas
gcloud logging read \
  "resource.type=global AND severity=ERROR" \
  --limit=20
```

### Permissões faltando

```bash
# Adicionar role necessária
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member=serviceAccount:monitoring@cloudservices.gserviceaccount.com \
  --role=roles/monitoring.alertPolicyAdmin
```

---

**Para mais informações:** [Cloud Monitoring Notification Channels](https://cloud.google.com/monitoring/support/notification-options)
