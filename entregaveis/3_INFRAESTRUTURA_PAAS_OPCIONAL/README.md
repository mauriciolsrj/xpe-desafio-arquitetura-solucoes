# 3. Infraestrutura PaaS - Provisionamento do Banco de Dados (OPCIONAL)

## Descrição

Este diretório contém os artefatos opcionais para provisionamento da infraestrutura PaaS (Platform as a Service), focado em banco de dados gerenciado, alta disponibilidade, backups e disaster recovery.

## Componentes PaaS

### 1. Cloud SQL - PostgreSQL 15 (Banco de Dados Gerenciado)

**Especificações do Banco de Dados:**
- Motor: PostgreSQL 15
- Tier: db-custom-4-16384 (16 vCPU, 16 GB RAM)
- Armazenamento: 100 GB SSD com autoresize até 500 GB
- Storage Type: SSD (Solid State Drive)

**Arquivo relacionado:** `../../infrastructure/terraform/sql.tf`

### 2. Alta Disponibilidade (HA) Regional

**High Availability Configuration:**
- Modo: Regional HA com Standby automático
- Primary: us-central1
- Standby: Mesma região, zona diferente (automático)
- Failover: Automático em caso de falha do primary
- RPO (Recovery Point Objective): Próximo a zero
- RTO (Recovery Time Objective): Segundos

**Arquivo relacionado:** `../../infrastructure/terraform/sql.tf`

### 3. Replicação Cross-Region para Disaster Recovery

**Read Replica Configuration:**
- Tipo: Read-Only Replica
- Localização: us-east1 (outra região)
- Propósito: Disaster Recovery (DR)
- Replicação: Assíncrona
- Failover Manual: Promove réplica a primary em caso de desastre regional

**Arquivo relacionado:** `../../infrastructure/terraform/sql.tf`

### 4. Backups e PITR (Point-in-Time Recovery)

**Backup Configuration:**
- Tipo: Backups automáticos
- Frequência: Diária às 3:00 AM UTC
- Retenção: 30 snapshots
- Armazenamento: Multi-regional
- PITR: Até 7 dias no passado
- Recuperação: Via backup específico ou PITR

**Arquivo relacionado:** `../../infrastructure/terraform/sql.tf`

### 5. Conexão Segura (Private Service Connect)

**Network Configuration:**
- Tipo: Private Service Connection (sem IP público)
- Acesso: Apenas via VPC interna
- Criptografia: SSL/TLS obrigatório
- Isolamento: Completamente privado

**Arquivo relacionado:** `../../infrastructure/terraform/sql.tf` e `vpc.tf`

### 6. Configuração de Backup Automático

**Automated Backups:**
- Automático todos os dias
- Retenção: 30 snapshots (30 dias)
- Localização: Global (multi-regional)
- Criptografia: Habilitada por padrão

## Código Terraform

Todo o código de provisionamento PaaS está disponível em:

```
../../infrastructure/terraform/
├── sql.tf              # Cloud SQL, HA, Replication, Backups
├── main.tf             # Providers e APIs para SQL
└── variables.tf        # Variáveis customizáveis
```

## Configurações de Segurança

**Deletion Protection:**
- Habilitado: Evita deleção acidental

**SSL/TLS Requirements:**
- Habilitado: Todas as conexões requerem SSL/TLS

**Database Flags:**
- Configurados conforme best practices do PostgreSQL

**Backup Encryption:**
- Habilitada por padrão

## Como Provisionar

```bash
cd ../../infrastructure/terraform

# 1. Preparar variáveis
cp terraform.tfvars.example terraform.tfvars
vim terraform.tfvars

# 2. Inicializar
terraform init

# 3. Validar
terraform validate

# 4. Planejar
terraform plan -out=tfplan

# 5. Aplicar (levará 15-20 minutos)
terraform apply tfplan
```

## Conexão ao Banco de Dados

### Via Cloud SQL Proxy

```bash
# Instalar proxy
curl -o cloud-sql-proxy https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64
chmod +x cloud-sql-proxy

# Conectar
./cloud-sql-proxy PROJECT:us-central1:ecommerce-postgres-primary
```

### Via psql (em outro terminal)

```bash
psql -h 127.0.0.1 -U app_user -d ecommerce
```

### Via Secret Manager (Recomendado)

```bash
# Armazenar senha
echo "PASSWORD" | gcloud secrets create db-password --data-file=-

# Recuperar em código
gcloud secrets versions access latest --secret="db-password"
```

## Operações Comuns

### Backup Manual

```bash
gcloud sql backups create --instance=ecommerce-postgres-primary
```

### Listar Backups

```bash
gcloud sql backups list --instance=ecommerce-postgres-primary
```

### Point-in-Time Recovery

```bash
# Restaurar em um ponto específico
gcloud sql backups restore BACKUP_ID \
  --backup-instance=ecommerce-postgres-primary \
  --target-instance=ecommerce-postgres-restore
```

### Promover Read Replica (DR)

```bash
# Em caso de desastre
gcloud sql instances promote-replica ecommerce-postgres-read-replica-dr
```

## Requisitos Atendidos

✓ Provisionar banco de dados gerenciado (Cloud SQL PostgreSQL)  
✓ Habilitar replicação multi-regional para DR  
✓ Configurar backups automáticos  
✓ Implementar PITR (Point-in-Time Recovery)  
✓ Alta disponibilidade com failover automático  
✓ Segurança com SSL/TLS e Private Service Connect  
✓ Classificação correta do banco como PaaS (não gerenciado pelo usuário)  

## Custo Estimado

- Cloud SQL Primary (Regional HA): ~$200/mês
- Cross-region Read Replica: Incluído no custo do primary
- Backups: Incluído no custo de armazenamento

## Recursos Adicionais

- [Cloud SQL Documentation](https://cloud.google.com/sql/docs)
- [Cloud SQL Best Practices](https://cloud.google.com/sql/docs/postgres/best-practices)
- [PostgreSQL 15 Documentation](https://www.postgresql.org/docs/15/)

---

**Autor:** Maurício Santos  
**Data:** Fevereiro 2026
