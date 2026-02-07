# PostgreSQL Financial Intelligence POC

Este repositório demonstra a aplicação de **SQL Avançado** para resolver problemas reais de auditoria e consolidação de dados em sistemas ERP de alta complexidade.

## 📌 O Problema
Em sistemas de gestão escolar e financeira, os dados costumam estar fragmentados entre múltiplos módulos (pedagógico, contratos, pagamentos e fiscal). Consolidar essas informações em tempo real exige queries performáticas que evitem o gargalo no banco de dados.

## 🛠️ Solução Proposta
A query demonstrada neste projeto utiliza técnicas de **Common Table Expressions (CTEs)** para organizar o fluxo de dados em três camadas:
1.  **Base de Faturamento:** Isolamento de matrículas e contratos ativos.
2.  **Detalhamento Financeiro:** Cálculo dinâmico de taxas de gateway de pagamento e conciliação.
3.  **Status Fiscal:** Integração de logs de emissão de notas fiscais (NFe/NFSe).

## 🚀 Conceitos Demonstrados
- **CTEs (Common Table Expressions):** Para legibilidade e organização de lógica complexa.
- **Lógica de Negócio no Banco:** Redução de processamento no Backend ao calcular taxas e status diretamente no PostgreSQL.
- **Joins e Agregações Otimizadas:** Manipulação de múltiplas tabelas mantendo a performance.
- **Análise de Inadimplência:** Uso de condicionais (`CASE WHEN`) para classificação automática de faturas.

**📂 Como visualizar:**
As implementações de SQL estão localizadas no diretório [`/scripts`](./scripts). 
A query principal de auditoria financeira pode ser encontrada [clicando aqui](./scripts/complex_billing_query.sql).