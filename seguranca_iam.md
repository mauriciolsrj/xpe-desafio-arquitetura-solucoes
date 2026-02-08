# Segurança e Controle de Acesso (IAM)

## Descrição

Este diretório contém os artefatos para implementação de segurança e controle de acesso (IAM), focado em proteger o acesso das máquinas virtuais ao banco de dados e outros recursos.

## Componentes de Segurança

### 1. Controle de Acesso (Cloud IAM)

**Service Account:**
- Serviço: Cloud IAM
- Nome: `ecommerce-vm-sa`
- Propósito: Identidade para VMs acessarem recursos GCP
- Princípio do Menor Privilégio: Apenas roles necessárias


### 2. Configuração de Roles (Papéis) do Cloud IAM

**Roles Configuradas:**

| Role | Descrição | Propósito |
|------|-----------|----------|
| `roles/cloudsql.client` | Acesso ao Cloud SQL | Leitura e escrita no banco de dados |
| `roles/logging.logWriter` | Escrita de logs | Enviar logs para Cloud Logging |
| `roles/monitoring.metricWriter` | Escrita de métricas | Enviar métricas para Cloud Monitoring |
| `roles/compute.instanceAdmin.v1` | Gerenciar instâncias | Controlar ciclo de vida das VMs |
| `roles/artifactregistry.reader` | Ler artifacts | Puxar imagens do registro |


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


### 4. Proteção contra Ataques (Cloud Armor)

**Proteção Implementada:**

- SQL Injection (SQLi): Prevenção com regra customizada
- Cross-Site Scripting (XSS): Prevenção com regra OWASP
- Protocol Attacks: Bloqueio de ataques de protocolo
- Scanner Detection: Detecção e bloqueio de scanners


### 5. Segurança da Rede (VPC)

**VPC Configuration:**

- Tipo: Privada (sem IPs públicos para VMs)
- Acesso a Internet: Cloud NAT (outbound)
- Isolamento: Subnet 10.0.1.0/24
- VPC Flow Logs: Habilitados para auditoria


### 6. Private Service Connect

**Database Connection:**

- Serviço: Private Service Connect
- Sem IP público para o banco de dados
- Conecta via network peering privado
- SSL/TLS: Obrigatório em todas as conexões
- Isolamento total da internet pública

---

**Autor:** Maurício Santos  
**Data:** 7 de fevereiro de 2026
