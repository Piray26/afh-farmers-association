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
