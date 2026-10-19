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
