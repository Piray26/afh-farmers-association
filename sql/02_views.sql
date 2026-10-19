-- Карточка члена ассоциации
CREATE OR REPLACE VIEW v_member_full_info AS
SELECT 
    m.member_id,
    m.farm_name,
    m.inn,
    m.ogrn,
    m.join_date,
    m.farm_address,
    b.branch_code,
    b.branch_name,
    r.region_name,
    r.federal_district,
    concat_ws(' ', cp.last_name, cp.first_name) AS contact_person,
    cp.phone AS contact_phone,
    fc.certificate_name,
    fc.valid_until
FROM members m
LEFT JOIN branches b ON m.branch_code = b.branch_code
LEFT JOIN regions r ON b.region_code = r.region_code
LEFT JOIN LATERAL (
    SELECT last_name, first_name, phone 
    FROM contact_persons 
    WHERE member_id = m.member_id 
    ORDER BY contact_id DESC LIMIT 1
) cp ON TRUE
LEFT JOIN LATERAL (
    SELECT certificate_name, valid_until 
    FROM farm_certificates 
    WHERE member_id = m.member_id AND valid_until >= CURRENT_DATE
    ORDER BY valid_until ASC LIMIT 1
) fc ON TRUE;

-- Сводка по коллективным закупкам
CREATE OR REPLACE VIEW v_collective_purchase_status AS
SELECT 
    cp.purchase_code,
    cp.purchase_name,
    c.organization_name AS supplier_name,
    cp.planned_date,
    cp.purchase_status,
    (SELECT COALESCE(SUM(ordered_quantity), 0) FROM purchase_participation WHERE purchase_code = cp.purchase_code) AS total_ordered,
    (SELECT COALESCE(SUM(quantity), 0) FROM product_shipments WHERE purchase_code = cp.purchase_code) AS total_shipped,
    (SELECT COALESCE(SUM(quantity_received), 0) FROM farm_resource_receipts WHERE purchase_code = cp.purchase_code) AS total_received
FROM collective_purchases cp
LEFT JOIN counterparties c ON cp.supplier_code = c.counterparty_code;

-- Показывает обращения, где нарушены внутренние нормативы (3 дня на ответ, 7 дней на решение)
CREATE OR REPLACE VIEW v_support_requests_dashboard AS
SELECT 
    sr.request_id,
    sr.request_date,
    sr.subject,
    sr.processing_status,
    m.member_id,
    m.farm_name,
    m.contact_phone AS member_phone,
    m.email AS member_email,
    b.branch_name,
    e.employee_id,
    concat_ws(' ', e.last_name, e.first_name) AS employee_name,
    e."position" AS employee_role,
    CURRENT_DATE - sr.request_date AS days_open,
    CASE 
        WHEN sr.processing_status IN ('Новое', 'В работе') THEN 'Активно'
        ELSE 'Закончено'
    END AS is_active
FROM support_requests sr
JOIN members m ON sr.member_id = m.member_id
LEFT JOIN branches b ON m.branch_code = b.branch_code
LEFT JOIN employees e ON sr.responsible_employee = e.employee_id;

CREATE OR REPLACE VIEW v_support_sla_breaches AS
SELECT 
    request_id,
    farm_name,
    subject,
    processing_status,
    days_open,
    CASE 
        WHEN processing_status = 'Новое' AND days_open > 3 THEN 'Нет ответа > 3 дней'
        WHEN processing_status = 'В работе' AND days_open > 7 THEN 'В работе > 7 дней'
    END AS sla_violation_reason,
    employee_name
FROM v_support_requests_dashboard
WHERE is_active = 'Активно'
  AND ( (processing_status = 'Новое' AND days_open > 3) 
     OR (processing_status = 'В работе' AND days_open > 7) );
CREATE OR REPLACE FUNCTION fn_hash_pii(p_text TEXT) RETURNS TEXT AS $$
BEGIN
    IF p_text IS NULL OR p_text = '' THEN RETURN p_text; END IF;
    RETURN encode(digest(p_text, 'sha256'), 'hex');
END;
$$ LANGUAGE plpgsql IMMUTABLE;

--Представление обращений
CREATE VIEW v_member_support_requests AS
SELECT
    request_id,
    member_id,
    request_date,
    subject,
    processing_status
FROM support_requests;


--Представление обращений
CREATE VIEW v_member_collective_purchases AS
SELECT
    cp.purchase_code,
    cp.purchase_name,
    cp.purchase_status,
    pp.member_id,
    pp.ordered_quantity,
    pp.actual_quantity
FROM collective_purchases cp
LEFT JOIN purchase_participation pp
ON cp.purchase_code = pp.purchase_code;



