CREATE TABLE public.regions (
    region_code character varying(10) NOT NULL,
    region_name character varying(100),
    federal_district character varying(50)
);
ALTER TABLE ONLY public.regions ADD CONSTRAINT regions_pkey PRIMARY KEY (region_code);

CREATE TABLE public.branches (
    branch_code character varying(10) NOT NULL,
    branch_name character varying(100),
    region_code character varying(10),
    office_address character varying(200),
    contact_phone character varying(20)
);
ALTER TABLE ONLY public.branches ADD CONSTRAINT branches_pkey PRIMARY KEY (branch_code);
ALTER TABLE ONLY public.branches ADD CONSTRAINT branches_ibfk_1 FOREIGN KEY (region_code) REFERENCES public.regions(region_code);

CREATE TABLE public.specializations (
    spec_code character varying(10) NOT NULL,
    spec_name character varying(100),
    category character varying(15)
);
ALTER TABLE ONLY public.specializations ADD CONSTRAINT specializations_pkey PRIMARY KEY (spec_code);

CREATE TABLE public.product_types (
    product_code character varying(10) NOT NULL,
    product_name character varying(100),
    unit_of_measure character varying(20),
    spec_code character varying(10)
);
ALTER TABLE ONLY public.product_types ADD CONSTRAINT product_types_pkey PRIMARY KEY (product_code);
ALTER TABLE ONLY public.product_types ADD CONSTRAINT product_types_ibfk_1 FOREIGN KEY (spec_code) REFERENCES public.specializations(spec_code);

CREATE TABLE public.sales_channels (
    channel_code character varying(10) NOT NULL,
    channel_name character varying(100),
    channel_type character varying(17)
);
ALTER TABLE ONLY public.sales_channels ADD CONSTRAINT sales_channels_pkey PRIMARY KEY (channel_code);

CREATE TABLE public.members (
    member_id integer DEFAULT nextval('public.seq_members_member_id'::regclass) NOT NULL,
    farm_name character varying(200),
    legal_form character varying(100),
    inn character varying(64),
    ogrn character varying(64),
    join_date date,
    contact_phone character varying(64),
    email character varying(64),
    farm_address character varying(200),
    branch_code character varying(10)
);
ALTER TABLE ONLY public.members ADD CONSTRAINT members_pkey PRIMARY KEY (member_id);
ALTER TABLE ONLY public.members ADD CONSTRAINT members_ibfk_1 FOREIGN KEY (branch_code) REFERENCES public.branches(branch_code);

CREATE TABLE public.contact_persons (
    contact_id integer DEFAULT nextval('public.seq_contact_persons_contact_id'::regclass) NOT NULL,
    member_id integer NOT NULL,
    last_name character varying(50),
    first_name character varying(50),
    middle_name character varying(50),
    "position" character varying(100),
    phone character varying(64),
    email character varying(64)
);
ALTER TABLE ONLY public.contact_persons ADD CONSTRAINT contact_persons_pkey PRIMARY KEY (contact_id);
ALTER TABLE ONLY public.contact_persons ADD CONSTRAINT contact_persons_ibfk_1 FOREIGN KEY (member_id) REFERENCES public.members(member_id);

CREATE TABLE public.employees (
    employee_id character varying(10) NOT NULL,
    last_name character varying(50),
    first_name character varying(50),
    middle_name character varying(50),
    branch_code character varying(10),
    "position" character varying(100),
    contact_phone character varying(20),
    email character varying(100)
);
ALTER TABLE ONLY public.employees ADD CONSTRAINT employees_pkey PRIMARY KEY (employee_id);
ALTER TABLE ONLY public.employees ADD CONSTRAINT employees_ibfk_1 FOREIGN KEY (branch_code) REFERENCES public.branches(branch_code);

CREATE TABLE public.counterparties (
    counterparty_code character varying(10) NOT NULL,
    organization_name character varying(200),
    counterparty_type character varying(10),
    inn character varying(12),
    contact_phone character varying(20),
    email character varying(100)
);
ALTER TABLE ONLY public.counterparties ADD CONSTRAINT counterparties_pkey PRIMARY KEY (counterparty_code);

CREATE TABLE public.farm_production (
    production_id integer DEFAULT nextval('public.farm_production_production_id_seq'::regclass) NOT NULL,
    member_id integer NOT NULL,
    product_code character varying(20) NOT NULL,
    production_date date NOT NULL,
    quantity numeric(12,3) NOT NULL,
    report_code character varying(20),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);
ALTER TABLE ONLY public.farm_production ADD CONSTRAINT farm_production_pkey PRIMARY KEY (production_id);
ALTER TABLE ONLY public.farm_production ADD CONSTRAINT fk_farm_production_member FOREIGN KEY (member_id) REFERENCES public.members(member_id);
ALTER TABLE ONLY public.farm_production ADD CONSTRAINT fk_farm_production_product FOREIGN KEY (product_code) REFERENCES public.product_types(product_code);

CREATE TABLE public.membership_fees (
    payment_number integer DEFAULT nextval('public.seq_membership_fees_payment_number'::regclass) NOT NULL,
    member_id integer NOT NULL,
    reporting_year smallint,
    amount numeric(10,2),
    payment_date date,
    payment_status character varying(17),
    basis_document_code character varying(10)
);
ALTER TABLE ONLY public.membership_fees ADD CONSTRAINT membership_fees_pkey PRIMARY KEY (payment_number);
ALTER TABLE ONLY public.membership_fees ADD CONSTRAINT membership_fees_ibfk_1 FOREIGN KEY (member_id) REFERENCES public.members(member_id);
ALTER TABLE ONLY public.membership_fees ADD CONSTRAINT membership_fees_ibfk_2 FOREIGN KEY (basis_document_code) REFERENCES public.internal_documents(document_code);

CREATE TABLE public.collective_purchases (
    purchase_code character varying(10) NOT NULL,
    purchase_name character varying(150),
    supplier_code character varying(10),
    responsible_branch character varying(10),
    planned_date date,
    purchase_status character varying(11),
    purchase_type character varying(20) DEFAULT 'mixed'::character varying,
    product_code character varying(20),
    unit_of_measure character varying(20)
);
ALTER TABLE ONLY public.collective_purchases ADD CONSTRAINT collective_purchases_pkey PRIMARY KEY (purchase_code);
ALTER TABLE ONLY public.collective_purchases ADD CONSTRAINT collective_purchases_ibfk_1 FOREIGN KEY (supplier_code) REFERENCES public.counterparties(counterparty_code);
ALTER TABLE ONLY public.collective_purchases ADD CONSTRAINT collective_purchases_ibfk_2 FOREIGN KEY (responsible_branch) REFERENCES public.branches(branch_code);
ALTER TABLE ONLY public.collective_purchases ADD CONSTRAINT fk_collective_purchase_product FOREIGN KEY (product_code) REFERENCES public.product_types(product_code);

CREATE TABLE public.farm_resource_receipts (
    receipt_id integer DEFAULT nextval('public.farm_resource_receipts_receipt_id_seq'::regclass) NOT NULL,
    purchase_code character varying(10),
    member_id integer,
    product_code character varying(10),
    quantity_received numeric(12,3) NOT NULL,
    receipt_date date DEFAULT CURRENT_DATE,
    note text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);
ALTER TABLE ONLY public.farm_resource_receipts ADD CONSTRAINT farm_resource_receipts_pkey PRIMARY KEY (receipt_id);
ALTER TABLE ONLY public.farm_resource_receipts ADD CONSTRAINT farm_resource_receipts_purchase_code_fkey FOREIGN KEY (purchase_code) REFERENCES public.collective_purchases(purchase_code);
ALTER TABLE ONLY public.farm_resource_receipts ADD CONSTRAINT farm_resource_receipts_member_id_fkey FOREIGN KEY (member_id) REFERENCES public.members(member_id);
ALTER TABLE ONLY public.farm_resource_receipts ADD CONSTRAINT farm_resource_receipts_product_code_fkey FOREIGN KEY (product_code) REFERENCES public.product_types(product_code);

CREATE TABLE public.support_requests (
    request_id integer DEFAULT nextval('public.seq_support_requests_request_id'::regclass) NOT NULL,
    member_id integer NOT NULL,
    request_date date,
    subject character varying(200),
    request_text text,
    processing_status character varying(8),
    responsible_employee character varying(10)
);
ALTER TABLE ONLY public.support_requests ADD CONSTRAINT support_requests_pkey PRIMARY KEY (request_id);
ALTER TABLE ONLY public.support_requests ADD CONSTRAINT support_requests_ibfk_1 FOREIGN KEY (member_id) REFERENCES public.members(member_id);
ALTER TABLE ONLY public.support_requests ADD CONSTRAINT support_requests_ibfk_2 FOREIGN KEY (responsible_employee) REFERENCES public.employees(employee_id);

CREATE TABLE public.events (
    event_code character varying(10) NOT NULL,
    event_name character varying(150),
    event_type character varying(11),
    start_date date,
    end_date date,
    location character varying(200),
    responsible_branch character varying(10)
);
ALTER TABLE ONLY public.events ADD CONSTRAINT events_pkey PRIMARY KEY (event_code);
ALTER TABLE ONLY public.events ADD CONSTRAINT events_ibfk_1 FOREIGN KEY (responsible_branch) REFERENCES public.branches(branch_code);

CREATE TABLE public.event_participation (
    participation_id integer NOT NULL,
    member_id integer NOT NULL,
    event_code character varying(10),
    registration_date date,
    attendance_status character varying(15)
);
ALTER TABLE ONLY public.event_participation ADD CONSTRAINT event_participation_pkey PRIMARY KEY (participation_id);
ALTER TABLE ONLY public.event_participation ADD CONSTRAINT event_participation_ibfk_1 FOREIGN KEY (member_id) REFERENCES public.members(member_id);
ALTER TABLE ONLY public.event_participation ADD CONSTRAINT event_participation_ibfk_2 FOREIGN KEY (event_code) REFERENCES public.events(event_code);

CREATE TABLE public.internal_documents (
    document_code character varying(10) NOT NULL,
    document_name character varying(150),
    document_type character varying(8),
    creation_date date,
    file_link character varying(500),
    author_id character varying(10)
);
ALTER TABLE ONLY public.internal_documents ADD CONSTRAINT internal_documents_pkey PRIMARY KEY (document_code);
ALTER TABLE ONLY public.internal_documents ADD CONSTRAINT internal_documents_ibfk_1 FOREIGN KEY (author_id) REFERENCES public.employees(employee_id);

CREATE TABLE public.long_term_projects (
    project_code character varying(10) NOT NULL,
    project_name character varying(150),
    project_goal text,
    start_date date,
    planned_end_date date,
    curator_id character varying(10)
);
ALTER TABLE ONLY public.long_term_projects ADD CONSTRAINT long_term_projects_pkey PRIMARY KEY (project_code);
ALTER TABLE ONLY public.long_term_projects ADD CONSTRAINT long_term_projects_ibfk_1 FOREIGN KEY (curator_id) REFERENCES public.employees(employee_id);

CREATE TABLE public.project_stages (
    stage_code character varying(10) NOT NULL,
    project_code character varying(10),
    report_year timestamp without time zone NOT NULL,
    funding_plan numeric(15,2),
    expected_results text
);
ALTER TABLE ONLY public.project_stages ADD CONSTRAINT project_stages_pkey PRIMARY KEY (stage_code);
ALTER TABLE ONLY public.project_stages ADD CONSTRAINT project_stages_ibfk_1 FOREIGN KEY (project_code) REFERENCES public.long_term_projects(project_code);

CREATE TABLE public.stage_reports (
    report_code character varying(10),
    stage_code character varying(10),
    actual_funding numeric(15,2),
    achieved_results text,
    report_date date
);
ALTER TABLE ONLY public.stage_reports ADD CONSTRAINT stage_reports_ibfk_1 FOREIGN KEY (stage_code) REFERENCES public.project_stages(stage_code);

CREATE TABLE public.services (
    service_code character varying(10) NOT NULL,
    service_name character varying(100),
    service_type character varying(12),
    base_cost numeric(10,2),
    branch_code character varying(10)
);
ALTER TABLE ONLY public.services ADD CONSTRAINT services_pkey PRIMARY KEY (service_code);
ALTER TABLE ONLY public.services ADD CONSTRAINT services_ibfk_1 FOREIGN KEY (branch_code) REFERENCES public.branches(branch_code);

CREATE TABLE public.service_requests (
    request_id integer NOT NULL,
    member_id integer NOT NULL,
    service_code character varying(10),
    request_date date,
    desired_date date,
    request_status character varying(9),
    employee_id character varying(10)
);
ALTER TABLE ONLY public.service_requests ADD CONSTRAINT service_requests_pkey PRIMARY KEY (request_id);
ALTER TABLE ONLY public.service_requests ADD CONSTRAINT service_requests_ibfk_1 FOREIGN KEY (member_id) REFERENCES public.members(member_id);
ALTER TABLE ONLY public.service_requests ADD CONSTRAINT service_requests_ibfk_2 FOREIGN KEY (service_code) REFERENCES public.services(service_code);
ALTER TABLE ONLY public.service_requests ADD CONSTRAINT service_requests_ibfk_3 FOREIGN KEY (employee_id) REFERENCES public.employees(employee_id);

CREATE TABLE public.product_movements (
    movement_id integer NOT NULL,
    member_id integer NOT NULL,
    product_code character varying(10) NOT NULL,
    movement_date date NOT NULL,
    quantity numeric(12,3) NOT NULL,
    movement_type character varying(30) NOT NULL,
    reference_doc character varying(50),
    note text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);
ALTER TABLE ONLY public.product_movements ADD CONSTRAINT product_movements_pkey PRIMARY KEY (movement_id);
ALTER TABLE ONLY public.product_movements ADD CONSTRAINT fk_product_movements_member FOREIGN KEY (member_id) REFERENCES public.members(member_id);
ALTER TABLE ONLY public.product_movements ADD CONSTRAINT fk_product_movements_product FOREIGN KEY (product_code) REFERENCES public.product_types(product_code);

CREATE TABLE public.product_shipments (
    shipment_id integer NOT NULL,
    purchase_code character varying(10) NOT NULL,
    member_id integer NOT NULL,
    product_code character varying(10) NOT NULL,
    quantity numeric(12,3) NOT NULL,
    shipment_date date DEFAULT CURRENT_DATE,
    status character varying(20) DEFAULT 'pending'::character varying,
    note text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);
ALTER TABLE ONLY public.product_shipments ADD CONSTRAINT product_shipments_pkey PRIMARY KEY (shipment_id);
ALTER TABLE ONLY public.product_shipments ADD CONSTRAINT fk_product_shipments_purchase FOREIGN KEY (purchase_code) REFERENCES public.collective_purchases(purchase_code);
ALTER TABLE ONLY public.product_shipments ADD CONSTRAINT fk_product_shipments_member FOREIGN KEY (member_id) REFERENCES public.members(member_id);
ALTER TABLE ONLY public.product_shipments ADD CONSTRAINT fk_product_shipments_product FOREIGN KEY (product_code) REFERENCES public.product_types(product_code);

CREATE TABLE public.purchase_participation (
    record_id integer NOT NULL,
    purchase_code character varying(10),
    member_id integer NOT NULL,
    ordered_quantity numeric(10,2),
    agreed_price numeric(10,2),
    payment_status character varying(17),
    actual_quantity numeric(12,3)
);
ALTER TABLE ONLY public.purchase_participation ADD CONSTRAINT purchase_participation_pkey PRIMARY KEY (record_id);
ALTER TABLE ONLY public.purchase_participation ADD CONSTRAINT fk_purchase_participation_purchase FOREIGN KEY (purchase_code) REFERENCES public.collective_purchases(purchase_code);
ALTER TABLE ONLY public.purchase_participation ADD CONSTRAINT purchase_participation_ibfk_2 FOREIGN KEY (member_id) REFERENCES public.members(member_id);

CREATE TABLE public.farm_certificates (
    certificate_code character varying(10),
    member_id integer NOT NULL,
    certificate_name character varying(200),
    issuing_authority character varying(150),
    issue_date date,
    valid_until date
);
ALTER TABLE ONLY public.farm_certificates ADD CONSTRAINT farm_certificates_ibfk_1 FOREIGN KEY (member_id) REFERENCES public.members(member_id);

CREATE TABLE public.farm_products (
    id integer NOT NULL,
    member_id integer NOT NULL,
    product_code character varying(10)
);
ALTER TABLE ONLY public.farm_products ADD CONSTRAINT farm_products_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.farm_products ADD CONSTRAINT farm_products_ibfk_1 FOREIGN KEY (member_id) REFERENCES public.members(member_id);
ALTER TABLE ONLY public.farm_products ADD CONSTRAINT farm_products_ibfk_2 FOREIGN KEY (product_code) REFERENCES public.product_types(product_code);

CREATE TABLE public.farm_performance (
    report_code character varying(10),
    member_id integer NOT NULL,
    report_year smallint,
    product_type_id integer NOT NULL,
    produced_volume numeric(15,2),
    main_sales_channel character varying(10)
);
ALTER TABLE ONLY public.farm_performance ADD CONSTRAINT farm_performance_ibfk_1 FOREIGN KEY (member_id) REFERENCES public.members(member_id);
ALTER TABLE ONLY public.farm_performance ADD CONSTRAINT farm_performance_ibfk_2 FOREIGN KEY (product_type_id) REFERENCES public.farm_products(id);
ALTER TABLE ONLY public.farm_performance ADD CONSTRAINT farm_performance_ibfk_3 FOREIGN KEY (main_sales_channel) REFERENCES public.sales_channels(channel_code);

CREATE TABLE public.role_credentials (
    role_name character varying(50) NOT NULL,
    password_salt text NOT NULL,
    password_hash text NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    is_active boolean DEFAULT true
);
ALTER TABLE ONLY public.role_credentials ADD CONSTRAINT role_credentials_pkey PRIMARY KEY (role_name);
