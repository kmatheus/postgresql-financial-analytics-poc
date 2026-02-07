-- =============================================================================
-- SQL Financeiro Avançado: Consolidação de Faturamento e Inadimplência
-- Objetivo: Consolidar dados de 20+ tabelas para auditoria de cobrança,
-- tratando descontos, taxas de cartão e status de integração fiscal.
-- =============================================================================

WITH billing_base AS (
    -- CTE para isolar o core da matrícula e contrato financeiro
    SELECT 
        std.id AS student_id,
        std.full_name AS student_name,
        enroll.id AS enrollment_id,
        cont.id AS contract_id,
        cont.total_value,
        -- Cálculo de competência
        TO_CHAR(inv.due_date, 'YYYY-MM') AS reference_month
    FROM students std
    INNER JOIN enrollments enroll ON std.id = enroll.student_id
    INNER JOIN contracts cont ON enroll.id = cont.enrollment_id
    INNER JOIN invoices inv ON cont.id = inv.contract_id
    WHERE std.is_active = TRUE
),

financial_details AS (
    -- CTE para processar parcelas, taxas de cartão e conciliação
    SELECT 
        inv_item.invoice_id,
        SUM(inv_item.amount) AS gross_value,
        -- Aplicação de lógica de taxas de bandeira (Stone/Gateways)
        SUM(inv_item.amount * (gate.fee_percentage / 100)) AS gateway_fees,
        COUNT(pay.id) FILTER (WHERE pay.status = 'confirmed') AS payments_count
    FROM invoice_items inv_item
    LEFT JOIN payments pay ON inv_item.id = pay.invoice_item_id
    LEFT JOIN gateway_configs gate ON pay.gateway_id = gate.id
    GROUP BY inv_item.invoice_id
),

fiscal_status AS (
    -- CTE para verificar integridade com a API FocusNFe
    SELECT 
        nf.invoice_id,
        nf.status AS nfe_status,
        nf.nfe_number,
        nf.issued_at
    FROM nfe_logs nf
    WHERE nf.is_latest = TRUE -- Garante apenas a última tentativa de emissão
)

-- Query Final: Consolidação para Relatório de Auditoria
SELECT 
    bb.student_name,
    bb.reference_month,
    fd.gross_value,
    fd.gateway_fees,
    (fd.gross_value - fd.gateway_fees) AS net_value,
    fs.nfe_status,
    fs.nfe_number,
    -- Case para determinar saúde financeira (Inadimplência)
    CASE 
        WHEN fd.payments_count = 0 AND CURRENT_DATE > (SELECT due_date FROM invoices WHERE id = fd.invoice_id) THEN 'OVERDUE'
        WHEN fd.payments_count = 0 THEN 'PENDING'
        ELSE 'PAID'
    END AS billing_status
FROM billing_base bb
JOIN financial_details fd ON bb.contract_id = (SELECT contract_id FROM invoices WHERE id = fd.invoice_id)
LEFT JOIN fiscal_status fs ON fd.invoice_id = fs.invoice_id
ORDER BY bb.reference_month DESC, bb.student_name ASC;