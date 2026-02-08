# Infraestrutura IaaS - Provisionamento de Máquinas Virtuais

## Descrição

Este diretório contém os artefatos para provisionamento da infraestrutura IaaS (Infrastructure as a Service), focado em máquinas virtuais, balanceamento de carga e escalabilidade automática.

## Componentes IaaS

### 1. Máquinas Virtuais em Múltiplas Zonas

Nas zonas: us-central1-a, us-central1-b, us-central1-c

**Especificações:**
- Imagem: Ubuntu 22.04 LTS Minimal
- Tipo de Máquina: e2-standard-2
- Escalonamento: 3-6 instâncias
- Managed Instance Group com distribuição regional

### 2. Balanceador de Carga

Cloud Load Balancing

**Especificações:**
- Tipo: HTTP/HTTPS
- Health Checks: Endpoint /health na porta 8080
- Redirect: HTTP → HTTPS automático
- Session Affinity: CLIENT_IP

### 3. Escalabilidade Automática (Autoscaling)

Managed Instance Group com políticas de Autoscaling

**Especificações:**
- Mínimo: 3 instâncias
- Máximo: 6 instâncias
- Trigger: CPU Utilization > 70%
- Scale-in Control: Máximo 1 instância a cada 10 minutos

### 4. Proteção contra Ataques

Cloud Armor para proteção contra SQLi, XSS e ataques de protocolo

**Especificações:**
- SQL Injection (SQLi) prevention
- Cross-Site Scripting (XSS) prevention
- Protocol attack protection
- Scanner detection

### 5. Rede e Firewall

VPC privada com Cloud NAT para acesso externo

**Especificações:**
- VPC: ecommerce-vpc
- Subnet: 10.0.1.0/24 (us-central1)
- Cloud NAT: Para acesso a internet das VMs privadas
- Firewall Rules:
  - GLB: 130.211.0.0/22, 35.191.0.0/16 (ports 80, 443, 8080)
  - Internal: 10.0.1.0/24 (all ports)
  - IAP SSH: 35.235.240.0/20 (port 22)

## Requisitos Atendidos

✓ Provisionar máquinas virtuais em múltiplas zonas de disponibilidade  
✓ Configurar balanceador de carga para distribuir tráfego  
✓ Implementar escalonamento automático (3-6 instâncias)  
✓ Utilizar imagens Linux (Ubuntu 22.04 LTS)  
✓ Limitar acesso via firewall para origens autorizadas  
✓ Implementar proteção contra ataques com Cloud Armor  

---

**Autor:** Maurício Santos  
**Data:** Fevereiro 2026

1. Instala Ops Agent para monitoramento
2. Instala Nginx como reverse proxy
3. Instala Node.js como runtime
4. Configura health check endpoint (/health)
5. Configura logging para Cloud Logging
6. Inicia coleta de métricas

## Requisitos Atendidos

✓ Provisionar máquinas virtuais em múltiplas zonas de disponibilidade  
✓ Configurar balanceador de carga para distribuir tráfego  
✓ Implementar escalonamento automático (3-6 instâncias)  
✓ Utilizar imagens Linux (Ubuntu 22.04 LTS)  
✓ Limitar acesso via firewall para origens autorizadas  

---

**Autor:** Maurício Santos  
**Data:** Fevereiro 2026

