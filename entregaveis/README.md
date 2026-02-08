# Entregáveis - Desafio Final Bootcamp Arquiteto de Soluções

## Bem-vindo

Este diretório contém todos os artefatos solicitados para o **Desafio Final do Bootcamp Arquiteto de Soluções**.

---

## ✅ Conformidade com Enunciado

**Status:** Todos os requisitos atendidos (5/5 obrigatórios + 4/4 opcionais implementados)

Para matriz completa de conformidade, consulte: [**VERIFICACAO_REQUISITOS.md**](VERIFICACAO_REQUISITOS.md)

### Requisitos Obrigatórios Implementados

| Requisito | Status | Pasta |
|-----------|--------|-------|
| Múltiplas zonas de disponibilidade | ✅ | 1_DIAGRAMA_ARQUITETURA |
| Balanceamento de carga | ✅ | 2_INFRAESTRUTURA_IAAS |
| Escalonamento automático (3-6 VMs Linux) | ✅ | 2_INFRAESTRUTURA_IAAS |
| Banco de dados gerenciado (PaaS) com HA | ✅ | 3_INFRAESTRUTURA_PAAS |
| Controle de acesso (IAM) para leitura/escrita no BD | ✅ | 4_SEGURANCA_IAM |

---

## 📁 Como Navegar

### 1️⃣ **Comece pelo Diagrama** (Obrigatório)

```
1_DIAGRAMA_ARQUITETURA/
├── arquitetura-solucao.mmd  ← Abra este arquivo
└── README.md               ← Leia a explicação
```

**O que encontra:**
- Diagrama visual de toda a arquitetura em Mermaid
- Componentes principais e suas integrações
- Referências aos serviços GCP utilizados

### 2️⃣ **Detalhes da Infraestrutura IaaS** (Opcional)

```
2_INFRAESTRUTURA_IAAS/
└── README.md
```

**O que encontra:**
- Máquinas virtuais em múltiplas zonas
- Cloud Load Balancing
- Autoscaling policies (3-6 instâncias)
- Firewall rules e segurança de rede
- Cloud Armor para proteção
- Como funciona a scalabilidade

### 3️⃣ **Detalhes do Banco de Dados PaaS** (Opcional)

```
3_INFRAESTRUTURA_PAAS/
└── README.md
```

**O que encontra:**
- Cloud SQL PostgreSQL 15
- Regional HA (High Availability)
- Read Replica cross-region para DR
- Backups automáticos
- Point-in-Time Recovery (PITR)
- Private Service Connect

### 4️⃣ **Segurança e Controle de Acesso** (Opcional)

```
4_SEGURANCA_IAM/
└── README.md
```

**O que encontra:**
- Cloud IAM Service Accounts e Roles
- Firewall rules detalhadas
- Cloud Armor rules
- Private Service Connect
- Princípio do menor privilégio
- Compliance e auditoria

### 5️⃣ **Monitoramento e Observabilidade** (Opcional)

```
5_MONITORAMENTO/
└── README.md
```

**O que encontra:**
- Cloud Logging (coleta de logs)
- Cloud Monitoring (coleta de métricas)
- Service Level Indicators (SLIs)
- Alertas configurados
- Dashboard customizado
- Ops Agent

---

## 🏗️ Estrutura de Pastas

```
entregaveis/
├── 1_DIAGRAMA_ARQUITETURA/
│   ├── README.md
│   └── arquitetura-solucao.mmd
│
├── 2_INFRAESTRUTURA_IAAS/
│   └── README.md
│
├── 3_INFRAESTRUTURA_PAAS/
│   └── README.md
│
├── 4_SEGURANCA_IAM/
│   └── README.md
│
├── 5_MONITORAMENTO/
│   └── README.md
│
├── README.md (este arquivo)
└── VERIFICACAO_REQUISITOS.md (matriz de conformidade)
```

---

## 🎯 Arquitetura Visual

```
                          End Users
                              ↓
                    Cloud Load Balancing
                        (HTTP/HTTPS)
                              ↓
                        Cloud Armor
                     (SQLi/XSS Protection)
                              ↓
        ┌─────────────────────┼─────────────────────┐
        ↓                      ↓                      ↓
    Zone A                 Zone B                 Zone C
  Instâncias            Instâncias             Instâncias
  (Ubuntu LTS)          (Ubuntu LTS)           (Ubuntu LTS)
  
        └─────────────────────┼─────────────────────┘
                              ↓
                    Private Service Connect
                              ↓
                        Cloud SQL Primary
                   (PostgreSQL 15, Regional HA)
                              ↓
                      Cloud SQL Replica
                      (us-east1, DR)
```

---

## 📊 Componentes Chave

### Requisitos Obrigatórios

**1. Múltiplas Zonas de Disponibilidade**
- 3 zonas: us-central1-a, us-central1-b, us-central1-c
- Garante continuidade mesmo com falha de uma zona
- Autoscaling distribui instâncias entre zonas

**2. Balanceamento de Carga**
- Cloud Load Balancing
- HTTP → HTTPS redirect automático
- Health checks na porta 8080
- Session affinity por IP do cliente

**3. Escalonamento Automático**
- Managed Instance Group com autoscaler regional
- Mínimo: 3 instâncias
- Máximo: 6 instâncias
- Trigger: CPU > 70%

**4. Banco PaaS com Alta Disponibilidade**
- Cloud SQL PostgreSQL 15
- Regional HA com Standby automático
- Read Replica em us-east1 para DR
- Backups automáticos + PITR (7 dias)
- Private Service Connect (sem IP público)

**5. Controle de Acesso (IAM)**
- Service Account: `ecommerce-vm-sa`
- Role `roles/cloudsql.client` para leitura/escrita
- Roles adicionais: logging.logWriter, monitoring.metricWriter

### Requisitos Opcionais (Implementados)

- ✅ **IaaS Completo**: VMs, Load Balancer, Autoscaling, Firewall
- ✅ **PaaS Completo**: Cloud SQL, PITR, Replicação, Backups
- ✅ **Segurança**: Cloud Armor, IAM, Private Conn, VPC privada
- ✅ **Monitoramento**: Cloud Logging, Cloud Monitoring, SLIs, Alertas

---

## 🔍 Verificação de Requisitos

Para verificar a conformidade completa com o enunciado:

**Abra:** [VERIFICACAO_REQUISITOS.md](VERIFICACAO_REQUISITOS.md)

Este arquivo contém:
- ✅ Matriz de todos os 9 requisitos
- ✅ Status de cada requisito
- ✅ Localização exata na documentação
- ✅ Como cada requisito foi atendido

---

## 💡 Destaques da Implementação

### Resiliência
- Multi-zone redundancy (3 zonas)
- Autoscaling automático
- Database failover < 1 minuto
- Read Replica para Disaster Recovery

### Segurança
- Cloud Armor com proteção OWASP
- Private Service Connect (BD sem IP público)
- VPC privada com Cloud NAT
- IAM com princípio do menor privilégio
- Firewall rules restritivas

### Observabilidade
- SLIs definidos (P99 Latency < 500ms, Error Rate < 1%)
- Cloud Logging para todos os logs
- Cloud Monitoring para métricas
- Dashboard customizado
- Alertas configurados

### Infraestrutura como Código
- Terraform pronto para produção
- Todos os componentes versionáveis
- Startup scripts automatizados
- Configuração como código

---

## 📚 Documentação Complementar

Para entender melhor cada aspecto:

1. **Diagrama da Arquitetura**
   - Arquivo: `1_DIAGRAMA_ARQUITETURA/arquitetura-solucao.mmd`
   - Visualize em: https://mermaid.live

2. **Código Terraform**
   - Localização: `../infrastructure/terraform/`
   - README: `../infrastructure/terraform/README.md`

3. **Scripts de Operações**
   - OPERATIONS.md: Guia de day-2 operations
   - NOTIFICATIONS.md: Configurar alertas

---

**Autor:** Maurício Santos  
**Data:** 7 de fevereiro de 2026  
**Status:** ✅ Completamente Implementado
