# 1. Diagrama da Arquitetura de Solução (OBRIGATÓRIO)

## Descrição

Este diretório contém o diagrama obrigatório da arquitetura de solução em nuvem que atende aos requisitos do Bootcamp Arquiteto de Soluções.

## Artefato: Desenho da Arquitetura de Soluções em Draw.io

### Arquivo Principal
- **logica-arquitetura.drawio** - Diagrama da arquitetura completa em formato Draw.io (importável no Draw.io)

Alternativamente:
- **logica-arquitetura.png** - Exportação em PNG para visualização
- **logica-arquitetura.pdf** - Exportação em PDF para documentação

### Componentes Inclusos no Diagrama

O diagrama inclui os seguintes componentes conforme exigido:

1. **Múltiplas Zonas de Disponibilidade**
   - Zone A (us-central1-a)
   - Zone B (us-central1-b)
   - Zone C (us-central1-c)

2. **Balanceamento de Carga**
   - Global External Application Load Balancer
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

5. **Controle de Acesso (IAM)**
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

7. **Monitoramento e Observabilidade**
   - Cloud Monitoring para métricas
   - Cloud Logging para logs
   - SLIs e alertas configurados
   - Dashboard customizado

## Como Abrir no Draw.io

1. Acesse [draw.io](https://draw.io)
2. Clique em "File" > "Open"
3. Selecione o arquivo **logica-arquitetura.drawio**
4. O diagrama será carregado com todos os componentes GCP

## Alinhamento com Requisitos

Este diagrama atende completamente todos os requisitos obrigatórios da atividade 1:

✓ Uso de múltiplas zonas de disponibilidade  
✓ Balanceamento de carga entre VMs  
✓ Escalonamento automático (3-6 instâncias, Linux)  
✓ Provisão de banco de dados gerenciado (PaaS)  
✓ Configuração de controle de acesso (IAM)  
✓ Mecanismos de failover e recuperação de desastres  

Diagrama detalhado incluindo:
- VMs em múltiplas zonas
- Load Balancer e distribuição de tráfego
- Banco de dados com replicação
- Mecanismos de failover automático
- Componentes de segurança (Cloud Armor, Firewall, IAM)

---

**Autor:** Maurício Santos  
**Data:** Fevereiro 2026

