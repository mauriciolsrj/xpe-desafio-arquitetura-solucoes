# Entregáveis - Desafio Final

## Bem-vindo

Este diretório contém todos os artefatos solicitados para o Desafio Final do Bootcamp Arquiteto de Soluções.

## Estrutura de Pastas

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
└── 5_MONITORAMENTO/
    └── README.md
```

## Componentes da Arquitetura

```
                          End Users
                              ↓
                        Global Load Balancer
                        (HTTP/HTTPS)
                              ↓
                        Cloud Armor
                     (SQLi/XSS Protection)
                              ↓
        ┌─────────────────────┼─────────────────────┐
        ↓                      ↓                      ↓
    Zone A                 Zone B                 Zone C
  Instances              Instances             Instances
  (Ubuntu LTS)           (Ubuntu LTS)          (Ubuntu LTS)
  
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

**Autor:** Maurício Santos  
**Data:** Fevereiro 2026
