# 2. Infraestrutura IaaS - Provisionamento de Máquinas Virtuais (OPCIONAL)

## Descrição

Este diretório contém os artefatos opcionais para provisionamento da infraestrutura IaaS (Infrastructure as a Service), focado em máquinas virtuais, balanceamento de carga e escalabilidade automática.

## Componentes IaaS

### 1. Máquinas Virtuais em Múltiplas Zonas

Nas zonas: us-central1-a, us-central1-b, us-central1-c

**Especificações:**
- Imagem: Ubuntu 22.04 LTS Minimal
- Tipo de Máquina: e2-standard-2 (customizável)
- Escalonamento: 3-6 instâncias
- Managed Instance Group (MIG) com distribuição regional

**Arquivo relacionado:** `../../infrastructure/terraform/compute.tf`

### 2. Balanceador de Carga

Global External Application Load Balancer

**Especificações:**
- Tipo: HTTP/HTTPS
- Health Checks: Endpoint /health na porta 8080
- Redirect: HTTP → HTTPS automático
- Session Affinity: CLIENT_IP

**Arquivo relacionado:** `../../infrastructure/terraform/load-balancer.tf`

### 3. Escalabilidade Automática (Autoscaling)

Managed Instance Group com políticas de autoscaling

**Especificações:**
- Mínimo: 3 instâncias
- Máximo: 6 instâncias
- Trigger: CPU Utilization > 70%
- Scale-in Control: Máximo 1 instância a cada 10 minutos
- Cooldown Period: Evita oscilações

**Arquivo relacionado:** `../../infrastructure/terraform/compute.tf`

### 4. Rede e Firewall

VPC privada com Cloud NAT para acesso externo

**Especificações:**
- VPC: ecommerce-vpc
- Subnet: 10.0.1.0/24 (us-central1)
- Cloud NAT: Para acesso a internet das VMs privadas
- Firewall Rules:
  - GLB: 130.211.0.0/22, 35.191.0.0/16 (ports 80, 443, 8080)
  - Internal: 10.0.1.0/24 (all ports)
  - IAP SSH: 35.235.240.0/20 (port 22)

**Arquivos relacionados:** 
- `../../infrastructure/terraform/vpc.tf`
- `../../infrastructure/terraform/main.tf`

## Código Terraform

Todo o código de provisionamento IaaS está disponível em:

```
../../infrastructure/terraform/
├── compute.tf          # Instance Template, MIG, Autoscaling
├── load-balancer.tf    # Global LB, Cloud Armor
├── vpc.tf              # VPC, Subnets, Firewall, Cloud NAT
├── main.tf             # Providers e APIs
└── variables.tf        # Variáveis customizáveis
```

## Script de Inicialização

Arquivo: `../../infrastructure/scripts/startup-script.sh`

O script executa automaticamente em cada VM e:
1. Instala Google Cloud Ops Agent para monitoramento
2. Instala Nginx como reverse proxy
3. Instala Node.js como runtime
4. Configura health check endpoint (/health)
5. Configura logging para Cloud Logging
6. Inicia coleta de métricas

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

# 5. Aplicar
terraform apply tfplan
```

## Requisitos Atendidos

✓ Provisionar máquinas virtuais em múltiplas zonas de disponibilidade  
✓ Configurar balanceador de carga para distribuir tráfego  
✓ Implementar escalonamento automático (3-6 instâncias)  
✓ Utilizar imagens Linux (Ubuntu 22.04 LTS)  
✓ Limitar acesso via firewall para origens autorizadas  
✓ Startup script automatizado para todas as instâncias  

## Monitoramento

As métricas de IaaS podem ser acompanhadas em:
- CPU Utilization (dispara autoscaling)
- Memory Usage
- Disk I/O
- Network Traffic
- Health Check Status

Veja `../../infrastructure/terraform/monitoring.tf` para detalhes dos alertas.

---

**Autor:** Maurício Santos  
**Data:** Fevereiro 2026
