-- Представления, процедуры, функции и триггеры из приложения Б.
-- Требует database/01_schema.sql. Используется расширение pgcrypto, включённое в схеме.
SET search_path = public;

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

-- При поступлении отгрузок или приёмки товаров автоматически меняет статус закупки
CREATE OR REPLACE FUNCTION fn_update_purchase_status() RETURNS TRIGGER AS $$
BEGIN
    UPDATE collective_purchases
    SET purchase_status = CASE 
        WHEN (SELECT COALESCE(SUM(quantity_received), 0) FROM farm_resource_receipts WHERE purchase_code = COALESCE(NEW.purchase_code, OLD.purchase_code)) > 0 THEN 'delivered'
        WHEN (SELECT COALESCE(SUM(quantity), 0) FROM product_shipments WHERE purchase_code = COALESCE(NEW.purchase_code, OLD.purchase_code)) > 0 THEN 'in_transit'
        ELSE 'planned'
    END
    WHERE purchase_code = COALESCE(NEW.purchase_code, OLD.purchase_code);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_cp_status_on_shipment
AFTER INSERT OR UPDATE ON product_shipments FOR EACH ROW
EXECUTE FUNCTION fn_update_purchase_status();

CREATE TRIGGER trg_cp_status_on_receipt
AFTER INSERT OR UPDATE ON farm_resource_receipts FOR EACH ROW
EXECUTE FUNCTION fn_update_purchase_status();

-- Запрещает создавать записи о производстве или движении продукции с нулевым/отрицательным количеством
CREATE OR REPLACE FUNCTION fn_validate_positive_quantity() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.quantity <= 0 THEN
        RAISE EXCEPTION 'Количество должно быть строго больше нуля. Получено: %', NEW.quantity;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_qty_check_production
BEFORE INSERT ON farm_production FOR EACH ROW EXECUTE FUNCTION fn_validate_positive_quantity();

CREATE TRIGGER trg_qty_check_movement
BEFORE INSERT ON product_movements FOR EACH ROW EXECUTE FUNCTION fn_validate_positive_quantity();

-- Одним вызовом создаёт ферму, контактное лицо и запись о взносе за текущий год. Использует существующие последовательности
CREATE OR REPLACE PROCEDURE sp_register_member(
    p_farm_name VARCHAR(200),
    p_legal_form VARCHAR(100),
    p_inn VARCHAR(12),
    p_ogrn VARCHAR(15),
    p_contact_phone VARCHAR(20),
    p_email VARCHAR(100),
    p_farm_address VARCHAR(200),
    p_branch_code VARCHAR(10)
)
LANGUAGE plpgsql AS $$
DECLARE
    v_member_id INTEGER;
BEGIN
    INSERT INTO members (member_id, farm_name, legal_form, inn, ogrn, join_date, contact_phone, email, farm_address, branch_code)
    VALUES (nextval('public.seq_members_member_id'), p_farm_name, p_legal_form, p_inn, p_ogrn, CURRENT_DATE, p_contact_phone, p_email, p_farm_address, p_branch_code)
    RETURNING member_id INTO v_member_id;

    INSERT INTO contact_persons (contact_id, member_id, last_name, first_name, "position", phone, email)
    VALUES (nextval('public.seq_contact_persons_contact_id'), v_member_id, 'Руководитель', 'Хозяйства', 'Директор', p_contact_phone, p_email);

    INSERT INTO membership_fees (payment_number, member_id, reporting_year, amount, payment_date, payment_status)
    VALUES (nextval('public.seq_membership_fees_payment_number'), v_member_id, EXTRACT(YEAR FROM CURRENT_DATE)::smallint, 0, NULL, 'pending');

    RAISE NOTICE 'Член ассоциации успешно зарегистрирован. ID: %', v_member_id;
END;
$$;

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


CREATE OR REPLACE FUNCTION fn_hash_contact_data() RETURNS TRIGGER AS $$
BEGIN
    NEW.phone := fn_hash_pii(NEW.phone);
    NEW.email := fn_hash_pii(NEW.email);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION fn_hash_member_data() RETURNS TRIGGER AS $$
BEGIN
    NEW.inn         := fn_hash_pii(NEW.inn);
    NEW.ogrn        := fn_hash_pii(NEW.ogrn);
    NEW.farm_address:= fn_hash_pii(NEW.farm_address);
    NEW.contact_phone:= fn_hash_pii(NEW.contact_phone);
    NEW.email       := fn_hash_pii(NEW.email);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION fn_auto_hash_password() RETURNS TRIGGER AS $$
DECLARE
    v_salt TEXT;
BEGIN
    IF NEW.password_hash IS NOT NULL AND LENGTH(NEW.password_hash) <> 64 THEN
        v_salt := encode(gen_random_bytes(16), 'hex');
        NEW.password_salt := v_salt;
        NEW.password_hash := encode(digest(NEW.password_hash || v_salt, 'sha256'), 'hex');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_hash_role_credentials
BEFORE INSERT ON role_credentials
FOR EACH ROW EXECUTE FUNCTION fn_auto_hash_password();

CREATE OR REPLACE FUNCTION fn_check_role_access(p_role_name TEXT, p_password TEXT) 
RETURNS BOOLEAN AS $$
    SELECT EXISTS (
        SELECT 1 FROM role_credentials 
        WHERE role_name = p_role_name 
          AND is_active = TRUE
          AND encode(digest(p_password || password_salt, 'sha256'), 'hex') = password_hash
    );
$$ LANGUAGE sql STABLE;
--Представление продукции
CREATE VIEW v_member_production AS
SELECT
    fp.production_id,
    fp.member_id,
    pt.product_name,
    fp.production_date,
    fp.quantity
FROM farm_production fp
JOIN product_types pt
ON pt.product_code = fp.product_code;

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

--Процедура для создания обращения
CREATE OR REPLACE PROCEDURE sp_create_support_request(
    p_member_id INTEGER,
    p_subject VARCHAR,
    p_text TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO support_requests(
        member_id,
        request_date,
        subject,
        request_text,
        processing_status
    )
    VALUES (
        p_member_id,
        CURRENT_DATE,
        p_subject,
        p_text,
        'Новое'
    );
END;
$$;

--Процедура для добавления продукции
CREATE OR REPLACE PROCEDURE sp_add_production(
    p_member_id INTEGER,
    p_product_code VARCHAR,
    p_quantity NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO farm_production(
        member_id,
        product_code,
        production_date,
        quantity
    )
    VALUES (
        p_member_id,
        p_product_code,
        CURRENT_DATE,
        p_quantity
    );
END;
$$;


--Триггер проверок
CREATE TRIGGER trg_validate_product_movements
BEFORE INSERT OR UPDATE
ON product_movements
FOR EACH ROW
EXECUTE FUNCTION fn_validate_positive_quantity();


-- Реестр просроченных членских взносов. Название представления упомянуто в разделе
-- администрирования исходной записки, но его DDL в приложениях отсутствовал.
CREATE OR REPLACE VIEW public.v_overdue_membership_fees AS
SELECT
    mf.payment_number,
    mf.member_id,
    m.farm_name,
    mf.reporting_year,
    mf.amount,
    mf.payment_date,
    mf.payment_status,
    mf.basis_document_code
FROM public.membership_fees mf
JOIN public.members m ON m.member_id = mf.member_id
WHERE mf.reporting_year < EXTRACT(YEAR FROM CURRENT_DATE)::smallint
  AND COALESCE(mf.payment_status, 'pending') <> 'Оплачено';

-- Совместимость с именем представления, использовавшимся в одном из листингов приложения.
CREATE OR REPLACE VIEW public.v_collective_purchase_status2 AS
SELECT * FROM public.v_collective_purchase_status;
