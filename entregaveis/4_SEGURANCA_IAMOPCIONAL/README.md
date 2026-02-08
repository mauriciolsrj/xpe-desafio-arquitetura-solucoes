# 4. Segurança e Controle de Acesso (IAM) (OPCIONAL)

## Descrição

Este diretório contém os artefatos opcionais para implementação de segurança e controle de acesso (IAM), focado em proteger o acesso das máquinas virtuais ao banco de dados e outros recursos.

## Componentes de Segurança

### 1. Service Account para VMs

**Service Account:**
- Nome: `ecommerce-vm-sa`
- Propósito: Identidade para VMs acessarem recursos GCP
- Princípio do Menor Privilégio: Apenas roles necessárias

**Arquivo relacionado:** `../../infrastructure/terraform/iam.tf`

### 2. Configuração de Roles (Papéis) do IAM

**Roles Configuradas:**

| Role | Descrição | Propósito |
|------|-----------|----------|
| `roles/cloudsql.client` | Acesso ao Cloud SQL | Leitura e escrita no banco de dados |
| `roles/logging.logWriter` | Escrita de logs | Enviar logs para Cloud Logging |
| `roles/monitoring.metricWriter` | Escrita de métricas | Enviar métricas para Cloud Monitoring |
| `roles/compute.instanceAdmin.v1` | Gerenciar instâncias | Controlar ciclo de vida das VMs |
| `roles/artifactregistry.reader` | Ler artifacts | Puxar imagens do registro |

**Arquivo relacionado:** `../../infrastructure/terraform/iam.tf`

### 3. Firewall Rules - Segurança de Rede

**Rules Implementadas:**

```
ALLOW (Global LB):
  Source: 130.211.0.0/22, 35.191.0.0/16
  Ports: 80, 443, 8080
  Direction: Ingress

ALLOW (Internal Traffic):
  Source: 10.0.1.0/24
  Ports: All
  Direction: Ingress

ALLOW (IAP SSH):
  Source: 35.235.240.0/20
  Port: 22
  Direction: Ingress

DENY (Everything Else):
  Default Rule (implícito)
```

**Arquivo relacionado:** `../../infrastructure/terraform/vpc.tf`

### 4. Cloud Armor - Proteção contra Ataques

**Proteção Implementada:**

- SQL Injection (SQLi): Prevenção com regra customizada
- Cross-Site Scripting (XSS): Prevenção com regra OWASP
- Protocol Attacks: Bloqueio de ataques de protocolo
- Scanner Detection: Detecção e bloqueio de scanners

**Arquivo relacionado:** `../../infrastructure/terraform/load-balancer.tf`

### 5. Segurança da Rede (VPC)

**VPC Configuration:**

- Tipo: Privada (sem IPs públicos para VMs)
- Acesso a Internet: Cloud NAT (outbound)
- Isolamento: Subnet 10.0.1.0/24
- VPC Flow Logs: Habilitados para auditoria

**Arquivo relacionado:** `../../infrastructure/terraform/vpc.tf`

### 6. Private Service Connection

**Database Connection:**

- Sem IP público para o banco de dados
- Conecta via network peering privado
- SSL/TLS: Obrigatório em todas as conexões
- Isolamento total da internet pública

**Arquivo relacionado:** `../../infrastructure/terraform/sql.tf`

## Código Terraform

Todo o código de segurança IAM está disponível em:

```
../../infrastructure/terraform/
├── iam.tf              # Service Accounts e Roles
├── vpc.tf              # Firewall Rules e Network Security
├── load-balancer.tf    # Cloud Armor Rules
├── sql.tf              # Private Service Connection
└── variables.tf        # Variáveis customizáveis
```

## Política de Segurança Implementada

### Princípio do Menor Privilégio

Cada VMs tem apenas as permissões estritamente necessárias:
- ✓ Acesso ao Cloud SQL (cloudsql.client)
- ✓ Envio de logs (logging.logWriter)
- ✓ Envio de métricas (monitoring.metricWriter)
- ✗ Acesso a buckets de storage (não necessário)
- ✗ Permissões de editor global (evitado)

### Segurança em Camadas (Defense in Depth)

1. **Camada 1 - Network:** Firewall Rules + VPC privada
2. **Camada 2 - Application:** Cloud Armor + WAF rules
3. **Camada 3 - Identity:** IAM Service Account + Roles
4. **Camada 4 - Data:** SSL/TLS + Private Service Connection

### Auditoria e Compliance

- Cloud Audit Logs: Rastreia todas as operações
- VPC Flow Logs: Monitora tráfego de rede
- Access Logs: Load Balancer registra todas as requisições
- Activity Logs: Mudanças IAM são auditadas

## Como Implementar

```bash
cd ../../infrastructure/terraform

# 1. Preparar variáveis
cp terraform.tfvars.example terraform.tfvars
vim terraform.tfvars

# 2. Inicializar
terraform init

# 3. Validar configuração de segurança
terraform validate

# 4. Revisar recursos IAM
terraform plan -target=google_service_account.vm_sa
terraform plan -target=google_project_iam_member.vm_cloudsql
# ... etc para outras roles

# 5. Aplicar com review
terraform apply tfplan
```

## Verificação de Segurança

### Verificar Service Account

```bash
gcloud iam service-accounts list --filter="email:ecommerce-vm-sa*"
gcloud iam service-accounts describe ecommerce-vm-sa@PROJECT.iam.gserviceaccount.com
```

### Verificar Roles Atribuídas

```bash
gcloud projects get-iam-policy PROJECT_ID \
  --flatten="bindings[].members" \
  --filter="bindings.members:serviceAccount:ecommerce-vm-sa*"
```

### Verificar Firewall Rules

```bash
gcloud compute firewall-rules list --filter="name:ecommerce*"
gcloud compute firewall-rules describe ecommerce-allow-glb
```

### Verificar Cloud Armor

```bash
gcloud compute security-policies list
gcloud compute security-policies describe ecommerce-armor-policy
```

## Requisitos de Segurança Atendidos

✓ Configurar políticas de IAM para controlar acesso das VMs ao banco de dados  
✓ Limitar acesso via firewall para origens autorizadas (GLB, IAP)  
✓ Implementar princípio do menor privilégio  
✓ Proteger contra SQLi, XSS e outros ataques (Cloud Armor)  
✓ Conexão segura ao banco de dados (Private Service Connect)  
✓ SSL/TLS obrigatório em todas as conexões  
✓ VPC privada para isolamento de rede  
✓ Auditoria de todas as ações via Cloud Audit Logs  

## Boas Práticas Implementadas

1. **Segregação de Responsabilidades:** Service Account separada para VMs
2. **Least Privilege:** Apenas roles estritamente necessárias
3. **Network Segmentation:** VPC privada com subnets específicas
4. **Defense in Depth:** Múltiplas camadas de segurança
5. **Encryption in Transit:** SSL/TLS em todas as conexões
6. **Logging & Monitoring:** Todas as ações são auditadas
7. **Compliance:** Alinhado com melhores práticas GCP

## Recursos Adicionais

- [GCP IAM Documentation](https://cloud.google.com/iam/docs)
- [Cloud Armor Documentation](https://cloud.google.com/armor/docs)
- [VPC Security Documentation](https://cloud.google.com/vpc/docs/firewalls)
- [Cloud SQL Security](https://cloud.google.com/sql/docs/postgres/security)
- [GCP Security Best Practices](https://cloud.google.com/security/best-practices)

---

**Autor:** Maurício Santos  
**Data:** Fevereiro 2026
