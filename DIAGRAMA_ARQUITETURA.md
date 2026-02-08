# Diagrama da Arquitetura de Solução

## Descrição

Este diretório contém o diagrama da arquitetura de solução em nuvem que atende aos requisitos do Bootcamp Arquiteto de Soluções.

## Artefato: Desenho da Arquitetura de Soluções

### Arquivos
- **arquitetura-solucao.mmd** - Diagrama da arquitetura completa em formato Mermaid

### Componentes Inclusos no Diagrama

1. **Múltiplas Zonas de Disponibilidade**
   - Zone A (us-central1-a)
   - Zone B (us-central1-b)
   - Zone C (us-central1-c)

2. **Balanceamento de Carga**
   - Cloud Load Balancing
   - Distribuição de tráfego HTTP/HTTPS
   - Health checks configurados

3. **Máquinas Virtuais com Escalonamento Automático**
   - Managed Instance Group (MIG) Regional
   - Mínimo: 3 instâncias
   - Máximo: 6 instâncias
   - Imagem: Ubuntu 22.04 LTS
   - CPU Target: 70%

4. **Banco de Dados como Serviço (PaaS)**
   - Cloud SQL PostgreSQL 15
   - Regional HA (High Availability)
   - Standby automático na mesma região
   - Read Replica em outra região para DR (us-east1)
   - Backups automáticos com PITR (7 dias)

5. **Controle de Acesso (Cloud IAM)**
   - Service Account para VMs
   - Roles configuradas:
     - cloudsql.client (acesso ao banco)
     - logging.logWriter (envio de logs)
     - monitoring.metricWriter (envio de métricas)

6. **Elementos de Segurança e Resiliência**
   - Cloud Armor para proteção (SQLi, XSS)
   - Firewall rules restringindo acesso
   - VPC privada com Cloud NAT
   - Failover automático do banco de dados
   - Cloud IAM para controle de acesso

7. **Monitoramento e Observabilidade**
   - Cloud Monitoring para métricas
   - Cloud Logging para logs
   - SLIs e alertas configurados
   - Dashboard customizado

---

**Autor:** Maurício Santos  
**Data:** 7 de fevereiro de 2026


