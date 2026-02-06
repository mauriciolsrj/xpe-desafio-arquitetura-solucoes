# Guia de Operação e Troubleshooting

## 🚀 Operações Comuns

### 1. Scale Manual da aplicação

```bash
# Aumentar instâncias manualmente (comanda autoscaler)
gcloud compute instance-groups managed set-autoscaling ecommerce-mig \
  --max-num-replicas 8 \
  --region=us-central1

# Redefinir autoscaling para default
gcloud compute instance-groups managed set-autoscaling ecommerce-mig \
  --min-num-replicas 3 \
  --max-num-replicas 6 \
  --target-cpu-utilization 0.70 \
  --region=us-central1
```

### 2. Atualizar Instâncias (Rolling Update)

```bash
# Atualizar instance template
terraform apply -target=google_compute_instance_template.app

# Iniciar rolling update
gcloud compute instance-groups managed rolling-action start-update \
  ecommerce-mig \
  --version template=projects/PROJECT/global/instanceTemplates/new-template \
  --region=us-central1

# Monitorar progresso
gcloud compute instance-groups managed describe ecommerce-mig \
  --region=us-central1
```

### 3. Drains e Retirada de Instância (Graceful Shutdown)

```bash
# Remover instância do Load Balancer (drain)
gcloud compute backend-services update ecommerce-backend-service \
  --enable-connection-draining \
  --connection-draining-timeout=300

# Esperar antes de deletar (permite requisições finalizarem)
sleep 300

# Deletar instância específica
gcloud compute instances delete INSTANCE_NAME --zone=ZONE
```

### 4. Verificar Saúde dos Recursos

```bash
# Health check do MIG
gcloud compute backend-services get-health ecommerce-backend-service --global

# Listar instâncias do MIG
gcloud compute instances list --filter="tags.items:ecommerce-instance"

# Ver detalhes de uma instância
gcloud compute instances describe INSTANCE_NAME --zone=ZONE

# Ver logs de startup script
gcloud compute instances get-serial-port-output INSTANCE_NAME --zone=ZONE
```

## 🐛 Troubleshooting

### Problema: Instâncias não passam em health check

**Sintomas:**
- MIG instances estão em estado "UNHEALTHY"
- Load Balancer não recebe tráfego

**Diagnóstico:**

```bash
# 1. Verificar status do health check
gcloud compute health-checks describe ecommerce-health-check

# 2. Testar manualmente o endpoint
gcloud compute instances list --filter="tags.items:http-server" \
  --format="value(networkInterfaces[0].networkIP)"

# Conectar via SSH e testar
gcloud compute ssh INSTANCE_NAME --zone=ZONE

# Dentro da instância
curl -v http://localhost:8080/health

# 3. Verificar logs do nginx
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log

# 4. Ver configuração do nginx
sudo nginx -t
sudo cat /etc/nginx/sites-available/default
```

**Soluções:**

- **Nginx não está rodando:** `sudo systemctl restart nginx`
- **Porta incorreta:** Editar `/etc/nginx/sites-available/default`
- **Firewall bloqueando:** Verificar security groups do VPC
- **Aplicação não respondendo:** Verificar logs de aplicação em `/var/log/ecommerce/`

### Problema: MIG não consegue fazer scale

**Sintomas:**
- Número de instâncias fica fixo
- CPU > 70% mas não escala

**Diagnóstico:**

```bash
# 1. Verificar status do autoscaler
gcloud compute instance-groups managed describe ecommerce-mig \
  --region=us-central1 \
  --format="value(autoscaledGroupPolicy)"

# 2. Ver histórico de scaling
gcloud logging read \
  "resource.type=instance_group_manager AND resource.label.name=ecommerce-mig" \
  --limit=20

# 3. Verificar métricas de CPU
gcloud monitoring timeseries list \
  --filter='metric.type="compute.googleapis.com/instance/cpu/utilization"'

# 4. Ver quotas
gcloud compute project-info describe --project=$(gcloud config get-value project) \
  --format="value(quotas[])"
```

**Soluções:**

- **Quota de instâncias excedida:** Abrir ticket com GCP para aumentar quota
- **Autoscaler desativado:** Reativar com `set-autoscaling`
- **Métrica não chegando:** Verificar Ops Agent nos logs

### Problema: Cloud SQL não conecta

**Sintomas:**
- Erro de conexão na aplicação
- Connection timeout/refused

**Diagnóstico:**

```bash
# 1. Verificar status da instância SQL
gcloud sql instances describe ecommerce-postgres-primary

# 2. Testar conectividade via Cloud SQL Proxy
gcloud cloud-sql-proxy ecommerce-postgres-primary

# Em outro terminal
psql -h 127.0.0.1 -U app_user -d ecommerce

# 3. Verificar Private Service Connection
gcloud compute networks peerings list --network=ecommerce-vpc

# 4. Verificar firewall rules
gcloud compute firewall-rules list --filter="name:ecommerce" --format=table

# 5. Ver logs de conexão
gcloud logging read \
  "resource.type=cloudsql_database AND severity>=ERROR" \
  --limit=20
```

**Soluções:**

- **Private Service Connection não criada:** Reexecutar terraform apply
- **Firewall bloqueando:** Verificar rules com `--source-ranges`
- **Service Account sem permissões:** Adicionar `roles/cloudsql.client`
- **Instância em estado "FAILURE":** Verificar alerts e backups

### Problema: Alto uso de CPU

**Sintomas:**
- CPU > 70% constantemente
- Servidor lento

**Diagnóstico:**

```bash
# 1. Ver top processes na instância
gcloud compute ssh INSTANCE_NAME --zone=ZONE
top -b -n 1 | head -20

# 2. Ver métricas de CPU via Cloud Monitoring
gcloud monitoring timeseries list \
  --filter='resource.type="gce_instance" AND metric.type="compute.googleapis.com/instance/cpu/utilization"' \
  --format=table

# 3. Analisar logs de aplicação
grep -r "ERROR\|WARN" /var/log/ecommerce/

# 4. Ver queries lentas no banco
psql -h 127.0.0.1 -U app_user -d ecommerce
SELECT * FROM pg_stat_statements ORDER BY mean_time DESC LIMIT 10;
```

**Soluções:**

- **Aplicação com leak de memória:** Reiniciar instância ou atualizar código
- **Query lenta no DB:** Adicionar índices ou otimizar query
- **Tráfego anormal:** Verificar logs de Cloud Armor
- **Máquina pequena:** Aumentar `machine_type` em terraform.tfvars

### Problema: Alertas não chegando

**Sintomas:**
- Alertas disparados mas sem notificação
- Não recebe emails ou Slack

**Diagnóstico:**

```bash
# 1. Verificar canais de notificação
gcloud alpha monitoring channels list

# 2. Verificar políticas de alerta
gcloud alpha monitoring policies list

# 3. Ver logs de tentativas de notificação
gcloud logging read \
  "protoPayload.methodName=monitoring.alertPolicies.*" \
  --limit=20

# 4. Testar notificação manualmente
gcloud alpha monitoring channels send-verification-code \
  --notification-channel=projects/PROJECT/notificationChannels/ID
```

**Soluções:**

- **Canal não configurado:** Seguir guia em [NOTIFICATIONS.md](./NOTIFICATIONS.md)
- **Email não validado:** Confirmar verificação de email no Cloud Console
- **Permissões faltando:** Adicionar `roles/monitoring.alertPolicyEditor`

## 📊 Monitoramento Proativo

### Dashboards Recomendados

1. **Painel Principal (SLIs)**
   - P99 Latency trend
   - Error Rate trend
   - Instance Count
   - CPU Utilization

2. **Painel de Banco de Dados**
   - Replicação lag
   - Conexões ativas
   - QPS (Queries per second)
   - Backup status

3. **Painel de Rede**
   - Traffic in/out
   - Error packets
   - Connection states

### Queries Úteis em Cloud Logging

```bash
# Erros nos últimos 24h
gcloud logging read \
  "severity>=ERROR AND timestamp>='2024-01-01T00:00:00Z'" \
  --limit=100 --format=json

# Requisições lentas
gcloud logging read \
  'jsonPayload.latency_ms > 500' \
  --limit=50

# Tráfego por zona
gcloud logging read \
  'resource.type="gce_instance"' \
  --format="table(resource.labels.zone, jsonPayload.bytes_sent)" \
  --limit=100
```

## 🔄 Procedimentos de Manutenção

### Backup Manual

```bash
# Criar backup manual
gcloud sql backups create \
  --instance=ecommerce-postgres-primary

# Listar backups
gcloud sql backups list --instance=ecommerce-postgres-primary

# Restaurar (criar nova instância)
gcloud sql backups restore BACKUP_ID \
  --backup-instance=ecommerce-postgres-primary \
  --target-instance=ecommerce-postgres-restored
```

### Atualização de Terraform

```bash
# Validar mudanças
terraform validate
terraform plan

# Aplicar mudanças (com estado remoto)
terraform apply

# Backup do state
terraform state pull > terraform.state.backup
```

### Cleanup de Recursos Antigos

```bash
# Listar backups antigos
gcloud sql backups list --instance=ecommerce-postgres-primary \
  --format="table(name,windowStartTime)" \
  --limit=50

# Limpar snapshots antigos
gcloud compute snapshots list --filter="creationTimestamp<'2023-06-01'" \
  --format=table --limit=50
```

## 📈 Capacity Planning

### Quando aumentar capacidade

- **CPU > 80% por mais de 1 hora**
  - Aumentar `max_instances` ou `machine_type`

- **Memória > 85%**
  - Aumentar RAM da máquina

- **Disco > 80%**
  - Aumentar tamanho do volume

- **Conexões DB > 150**
  - Aumentar pool de conexões na app

### Aumentar Capacidade

```bash
# Aumentar máximo de instâncias
terraform apply -var="max_instances=10"

# Aumentar tipo de máquina
terraform apply -var="machine_type=e2-standard-4"

# Aumentar Cloud SQL
gcloud sql instances patch ecommerce-postgres-primary \
  --tier=db-custom-8-32768

# Aumentar disco
gcloud sql instances patch ecommerce-postgres-primary \
  --database-flags cloudsql-instance-max-allocated-storage=500
```

## 🔐 Segurança

### Rotação de Credenciais

```bash
# Gerar nova senha para DB
password=$(openssl rand -base64 32)
gcloud sql users set-password app_user \
  --instance=ecommerce-postgres-primary \
  --password=$password

# Armazenar em Secret Manager
echo "$password" | gcloud secrets create db-password --data-file=-

# Atualizar nas apps
gcloud compute instances add-metadata INSTANCE \
  --metadata="db-password=$password" \
  --zone=ZONE
```

### Auditoria

```bash
# Ver quem acessou o quê
gcloud logging read \
  "protoPayload.methodName=compute.instances.get OR protoPayload.methodName=sql.*" \
  --format=json | jq '.[] | {time:.timestamp, user:.protoPayload.authenticationInfo.principalEmail, action:.protoPayload.methodName}'
```

---

**Para mais ajuda:** Consulte [GCP Monitoring Troubleshooting](https://cloud.google.com/monitoring/support/troubleshooting)
