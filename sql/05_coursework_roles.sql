-- Групповые роли из раздела 2.2 пояснительной записки.
-- Выполнять после 01_schema.sql и 02_views_functions_triggers.sql.
-- Здесь нет паролей; роли не предназначены для интерактивного входа (NOLOGIN).
CREATE ROLE afh_accountant NOLOGIN;
CREATE ROLE afh_support_manager NOLOGIN;
CREATE ROLE afh_member NOLOGIN;
CREATE ROLE afh_purchase_manager NOLOGIN;

GRANT USAGE ON SCHEMA public TO afh_accountant, afh_support_manager, afh_member, afh_purchase_manager;

-- Бухгалтерия
GRANT SELECT ON public.members, public.membership_fees, public.internal_documents,
    public.collective_purchases, public.purchase_participation TO afh_accountant;
GRANT UPDATE (payment_status, payment_date, basis_document_code)
    ON public.membership_fees TO afh_accountant;
GRANT INSERT ON public.internal_documents TO afh_accountant;
GRANT SELECT ON public.v_member_full_info, public.v_collective_purchase_status,
    public.v_overdue_membership_fees TO afh_accountant;

-- Служба поддержки
GRANT SELECT, INSERT, UPDATE ON public.support_requests TO afh_support_manager;
GRANT SELECT ON public.members, public.employees, public.branches,
    public.v_support_requests_dashboard, public.v_support_sla_breaches TO afh_support_manager;
REVOKE ALL ON public.membership_fees, public.purchase_participation,
    public.farm_production, public.product_movements FROM afh_support_manager;

-- Фермер-участник
GRANT SELECT, INSERT ON public.farm_production, public.product_movements,
    public.support_requests, public.purchase_participation TO afh_member;
GRANT SELECT ON public.product_types, public.collective_purchases, public.v_member_production,
    public.v_member_support_requests, public.v_member_collective_purchases TO afh_member;
GRANT USAGE, SELECT ON SEQUENCE public.farm_production_production_id_seq,
    public.product_movements_movement_id_seq, public.seq_support_requests_request_id,
    public.seq_purchase_participation_record_id TO afh_member;

-- Менеджер по закупкам
GRANT SELECT ON public.counterparties, public.branches, public.product_types TO afh_purchase_manager;
GRANT SELECT, INSERT, UPDATE ON public.collective_purchases,
    public.purchase_participation, public.product_shipments,
    public.farm_resource_receipts TO afh_purchase_manager;
GRANT USAGE, SELECT ON SEQUENCE public.product_shipments_shipment_id_seq,
    public.farm_resource_receipts_receipt_id_seq,
    public.seq_purchase_participation_record_id TO afh_purchase_manager;
