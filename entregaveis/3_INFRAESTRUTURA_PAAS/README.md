# Infraestrutura PaaS - Provisionamento do Banco de Dados

## Descrição

Este diretório contém os artefatos para provisionamento da infraestrutura PaaS (Platform as a Service), focado em banco de dados gerenciado, alta disponibilidade, backups e disaster recovery.

## Componentes PaaS

### 1. Cloud SQL - PostgreSQL 15 (Banco de Dados Gerenciado)

**Especificações:**
- Serviço: Cloud SQL
- Motor: PostgreSQL 15
- Tier: db-custom-4-16384 (16 vCPU, 16 GB RAM)
- Armazenamento: 100 GB SSD com autoresize até 500 GB

### 2. Alta Disponibilidade (HA) Regional

**Configuração:**
- Modo: Regional HA com Standby automático
- Primary: us-central1
- Standby: Mesma região, zona diferente (automático)
- Failover: Automático em caso de falha do primary

### 3. Replicação Cross-Region para Disaster Recovery

**Configuração:**
- Tipo: Read-Only Replica
- Localização: us-east1 (outra região)
- Propósito: Disaster Recovery (DR)
- Replicação: Assíncrona

### 4. Backups e PITR (Point-in-Time Recovery)

**Configuração:**
- Tipo: Backups automáticos
- Frequência: Diária
- Retenção: 30 snapshots
- PITR: Até 7 dias no passado

### 5. Conexão Segura (Private Service Connect)

**Configuração:**
- Serviço: Private Service Connect
- Tipo: Conexão privada (sem IP público)
- Acesso: Apenas via VPC interna
- Criptografia: SSL/TLS obrigatório
- Isolamento: Completamente privado

---

**Autor:** Maurício Santos  
**Data:** 7 de fevereiro de 2026
