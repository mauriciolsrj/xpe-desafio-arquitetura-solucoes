# Monitoramento e Observabilidade

## Descrição

Este diretório contém os artefatos para implementação de monitoramento completo e observabilidade, focado em rastreamento de desempenho, segurança e detecção de falhas.

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
| SQL Query Performance | Cloud SQL | Monitora queries lentas |


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


### 6. Ops Agent - Coleta Automática

**Instalação:**
- Automática via startup script
- Configuração em `/etc/google-cloud-ops-agent/config.yaml`
- Reinicia com a VM

**Funcionalidades:**
- Instalação automática via startup script
- Coleta de métricas do SO (CPU, Memória, Disco, Network)
- Coleta de logs de sistema
- Coleta de logs de aplicação (JSON parsing automático)
- Envio para Cloud Monitoring e Cloud Logging

## Requisitos de Monitoramento Atendidos

✓ Habilitar logs e monitoramento para desempenho, segurança e falhas  
✓ Cloud Logging para coleta de logs (system, app, cloud)  
✓ Cloud Monitoring para coleta de métricas  
✓ SLIs definido (P99 Latency, Error Rate)  
✓ Alertas configurados para anomalias  
✓ Dashboard customizado com gráficos principais  
✓ Ops Agent instalado em todas as VMs  
✓ Notificações via múltiplos canais  
