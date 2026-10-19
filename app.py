from bottle import Bottle, request, response, template, redirect, static_file, run, abort, TEMPLATE_PATH
from db import get_conn, execute_query
import hashlib, hmac, json
import os
import psycopg2
import traceback
from bottle import HTTPResponse

TEMPLATE_PATH.insert(0, './views')

app = Bottle()

APP_SECRET = os.getenv("BOTTLE_SECRET_KEY", "afh_coursework_secret_key_2024")

# Декоратор проверки ролей
def require_role(*roles):
    def decorator(func):
        def wrapper(*args, **kwargs):
            role = request.get_cookie("afh_role", secret=APP_SECRET)
            if not role or role not in roles:
                abort(403, "Доступ запрещен")
            return func(*args, **kwargs)
        return wrapper
    return decorator

@app.route('/')
def index():
    redirect('/login')


@app.route('/login', method=['GET', 'POST'])
def login():
    error = None

    if request.method == 'POST':
        role_name = request.forms.get('role_name', '').strip()
        password = request.forms.get('password', '')

        try:
            conn = get_conn()
            cur = conn.cursor()

            cur.execute(
                "SELECT public.fn_check_role_access(%s, %s)",
                (role_name, password)
            )

            result = cur.fetchone()

            cur.close()
            conn.close()

            if result:
                is_valid = bool(next(iter(result.values())))
            else:
                is_valid = False

            if is_valid:
                response.set_cookie(
                    "afh_role",
                    role_name,
                    secret=APP_SECRET,
                    httponly=True,
                    max_age=3600
                )

                redirect('/dashboard')

            error = "Неверный логин или пароль"

        except HTTPResponse:
            raise

        except Exception as e:
            traceback.print_exc()
            error = f"{type(e).__name__}: {e}"

    return template('login.tpl', error=error)

@app.route('/logout')
def logout():
    response.delete_cookie("afh_role", secret=APP_SECRET)
    redirect('/login')

@app.route('/dashboard')
@require_role('afh_member', 'afh_accountant', 'afh_support_manager', 'afh_purchase_manager')
def dashboard():
    role = request.get_cookie("afh_role", secret=APP_SECRET)
    return template('dashboard.tpl', role=role)

@app.route('/production', method=['GET', 'POST'])
@require_role('afh_member', 'afh_accountant')
def production():

    role = request.get_cookie(
        "afh_role",
        secret=APP_SECRET
    )

    error = None
    success = None

    try:

        products = execute_query("""
            SELECT
                product_code,
                product_name,
                unit_of_measure
            FROM public.product_types
            ORDER BY product_name
        """)

    except Exception as e:

        products = []
        error = f"Ошибка загрузки справочника: {e}"

    if request.method == 'POST':

        try:

            member_id = request.forms.get(
                'member_id',
                type=int
            )

            product_code = request.forms.get(
                'product_code',
                ''
            ).strip()

            quantity = request.forms.get(
                'quantity',
                type=float
            )

            if not member_id:
                raise Exception(
                    "Не указан ID фермера"
                )

            if not product_code:
                raise Exception(
                    "Не выбрана продукция"
                )

            if quantity is None or quantity <= 0:
                raise Exception(
                    "Количество должно быть больше нуля"
                )

            execute_query(
                """
                CALL public.sp_add_production(
                    %s,
                    %s,
                    %s
                )
                """,
                (
                    member_id,
                    product_code,
                    quantity
                ),
                fetch=False
            )

            success = (
                "Запись о производстве "
                "успешно добавлена!"
            )

        except Exception as e:

            error = f"Ошибка: {e}"

    return template(
        'production.tpl',
        role=role,
        products=products,
        error=error,
        success=success
    )

@app.route('/purchases', method=['GET', 'POST'])
@require_role('afh_member', 'afh_purchase_manager', 'afh_accountant')
def purchases():

    role = request.get_cookie("afh_role", secret=APP_SECRET)

    error = None
    success = None

    try:
        purchases_list = execute_query("""
            SELECT *
            FROM public.v_collective_purchase_status2
            ORDER BY planned_date DESC
        """)
    except Exception as e:
        purchases_list = []
        error = f"Ошибка загрузки закупок: {e}"

    if request.method == 'POST':

        try:
            member_id = request.forms.get('member_id', type=int)
            purchase_code = request.forms.get('purchase_code', '').strip()
            ordered_qty = request.forms.get('ordered_qty', type=float)

            if not member_id:
                raise Exception("Не указан участник")

            if not purchase_code:
                raise Exception("Не выбрана закупка")

            if ordered_qty is None or ordered_qty <= 0:
                raise Exception("Количество должно быть больше нуля")

            # Проверяем существование закупки
            purchase = execute_query("""
                SELECT purchase_code
                FROM public.collective_purchases
                WHERE purchase_code = %s
            """, (purchase_code,))

            if not purchase:
                raise Exception("Закупка не найдена")

            # Проверяем, не зарегистрирован ли уже участник
            exists = execute_query("""
                SELECT 1
                FROM public.purchase_participation
                WHERE purchase_code = %s
                  AND member_id = %s
            """, (purchase_code, member_id))

            if exists:
                raise Exception(
                    "Вы уже участвуете в данной закупке"
                )

            # Получаем новый record_id
            new_id = execute_query("""
                SELECT COALESCE(MAX(record_id), 0) + 1 AS id
                FROM public.purchase_participation
            """)[0]['id']

            # Создаем заявку
            execute_query("""
                INSERT INTO public.purchase_participation
                (
                    record_id,
                    purchase_code,
                    member_id,
                    ordered_quantity,
                    payment_status
                )
                VALUES
                (
                    %s,
                    %s,
                    %s,
                    %s,
                    'Ожидает оплаты'
                )
            """,
            (
                new_id,
                purchase_code,
                member_id,
                ordered_qty
            ),
            fetch=False)

            success = (
                f"Заявка на участие в закупке "
                f"{purchase_code} успешно создана"
            )

        except Exception as e:
            error = f"Ошибка: {e}"

    return template(
        'purchases.tpl',
        role=role,
        purchases=purchases_list,
        error=error,
        success=success
    )

# Обращения в региональные отделения
@app.route('/support', method=['GET', 'POST'])
@require_role('afh_member', 'afh_support_manager')
def support():
    role = request.get_cookie("afh_role", secret=APP_SECRET)
    error, success = None, None
    if request.method == 'POST':
        member_id = request.forms.get('member_id', type=int)
        subject = request.forms.get('subject').strip()
        text = request.forms.get('text').strip()
        try:
            execute_query("CALL public.sp_create_support_request(%s, %s, %s)", (member_id, subject, text), fetch=False)
            success = "Обращение успешно создано и передано в обработку."
        except Exception as e:
            error = f"Ошибка: {str(e)}"
    return template('support.tpl', role=role, error=error, success=success)

@app.route('/static/<filename:path>')
def serve_static(filename):
    return static_file(filename, root='static')


@app.route('/support_requests', method=['GET', 'POST'])
@require_role('afh_support_manager')
def support_requests():

    error = None
    success = None

    if request.method == 'POST':
        request_id = request.forms.get('request_id', type=int)
        status = request.forms.get('status')

        try:
            execute_query("""
                UPDATE support_requests
                SET processing_status=%s
                WHERE request_id=%s
            """, (status, request_id), fetch=False)

            success = "Статус обновлён"

        except Exception as e:
            error = str(e)

    requests = execute_query("""
        SELECT *
        FROM support_requests
        ORDER BY request_date DESC
    """)

    return template(
        'support_requests.tpl',
        requests=requests,
        error=error,
        success=success
    )

@app.route('/reference_data')
@require_role('afh_support_manager')
def reference_data():

    branches = execute_query(
        "SELECT * FROM branches ORDER BY branch_name"
    )

    employees = execute_query(
        "SELECT * FROM employees ORDER BY last_name, first_name"
    )

    members = execute_query(
        "SELECT * FROM members ORDER BY farm_name"
    )

    return template(
        'reference_data.tpl',
        branches=branches,
        employees=employees,
        members=members
    )

@app.route('/purchase_manager')
@require_role('afh_purchase_manager')
def purchase_manager():
    return template('purchase_manager.tpl')

@app.route('/collective_purchases', method=['GET', 'POST'])
@require_role('afh_purchase_manager')
def collective_purchases():

    error = None
    success = None

    if request.method == 'POST':

        action = request.forms.get('action')
        original_code = request.forms.get('original_purchase_code', '').strip()

        try:
            if action == 'add':
                execute_query("""
                    INSERT INTO collective_purchases
                    (purchase_code, purchase_name, supplier_code, responsible_branch, 
                     planned_date, purchase_status, purchase_type, unit_of_measure)
                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
                """, (
                    request.forms.get('purchase_code'),
                    request.forms.get('purchase_name'),
                    request.forms.get('supplier_code'),
                    request.forms.get('responsible_branch'),
                    request.forms.get('planned_date'),
                    request.forms.get('purchase_status'),
                    request.forms.get('purchase_type'),
                    request.forms.get('unit_of_measure')
                ), fetch=False)
                success = "✅ Закупка успешно создана"

            elif action == 'edit':
                if not original_code:
                    raise Exception("Ошибка: не указан оригинальный код закупки")
                
                execute_query("""
                    UPDATE collective_purchases
                    SET purchase_code=%s,
                        purchase_name=%s,
                        supplier_code=%s,
                        responsible_branch=%s,
                        planned_date=%s,
                        purchase_status=%s,
                        purchase_type=%s,
                        unit_of_measure=%s
                    WHERE purchase_code=%s
                """, (
                    request.forms.get('purchase_code'),
                    request.forms.get('purchase_name'),
                    request.forms.get('supplier_code'),
                    request.forms.get('responsible_branch'),
                    request.forms.get('planned_date'),
                    request.forms.get('purchase_status'),
                    request.forms.get('purchase_type'),
                    request.forms.get('unit_of_measure'),
                    original_code
                ), fetch=False)
                success = "✅ Закупка успешно обновлена"

        except Exception as e:
            error = f"❌ Ошибка: {str(e)}"

    purchases = execute_query("SELECT * FROM collective_purchases ORDER BY planned_date DESC")
    suppliers = execute_query("SELECT counterparty_code, organization_name FROM counterparties ORDER BY organization_name")
    branches = execute_query("SELECT branch_code, branch_name FROM branches ORDER BY branch_name")

    return template(
        'collective_purchases.tpl',
        purchases=purchases,
        suppliers=suppliers,
        branches=branches,
        error=error,
        success=success
    )

@app.route('/product_shipments')
@require_role('afh_purchase_manager')
def product_shipments():

    shipments = execute_query("""
        SELECT *
        FROM product_shipments
        ORDER BY shipment_date DESC
    """)

    return template(
        'product_shipments.tpl',
        shipments=shipments
    )

@app.route('/purchase_participants')
@require_role('afh_purchase_manager')
def purchase_participants():

    participants = execute_query("""
        SELECT *
        FROM purchase_participation
        ORDER BY record_id DESC
    """)

    return template(
        'purchase_participants.tpl',
        participants=participants
    )


@app.route('/membership_fees', method=['GET', 'POST'])
@require_role('afh_accountant')
def membership_fees():

    error = None
    success = None

    if request.method == 'POST':
        action = request.forms.get('action')
        original_payment_number = request.forms.get('original_payment_number', type=int)

        payment_date = request.forms.get('payment_date', '').strip()
        if not payment_date:
            payment_date = None

        try:
            if action == 'add':
                execute_query("""
                    INSERT INTO membership_fees
                    (member_id, reporting_year, amount, payment_date, payment_status, basis_document_code)
                    VALUES (%s, %s, %s, %s, %s, %s)
                """, (
                    request.forms.get('member_id', type=int),
                    request.forms.get('reporting_year', type=int),
                    request.forms.get('amount', type=float),
                    payment_date, 
                    request.forms.get('payment_status'),
                    request.forms.get('basis_document_code')
                ), fetch=False)
                success = "✅ Взнос успешно добавлен"

            elif action == 'edit':
                if not original_payment_number:
                    raise Exception("Ошибка: не указан номер платежа")
                
                execute_query("""
                    UPDATE membership_fees
                    SET member_id=%s,
                        reporting_year=%s,
                        amount=%s,
                        payment_date=%s,
                        payment_status=%s,
                        basis_document_code=%s
                    WHERE payment_number=%s
                """, (
                    request.forms.get('member_id', type=int),
                    request.forms.get('reporting_year', type=int),
                    request.forms.get('amount', type=float),
                    payment_date,
                    request.forms.get('payment_status'),
                    request.forms.get('basis_document_code'),
                    original_payment_number
                ), fetch=False)
                success = "✅ Взнос успешно обновлен"

        except Exception as e:
            error = f"❌ Ошибка: {str(e)}"

    fees = execute_query("""
        SELECT * FROM membership_fees
        ORDER BY reporting_year DESC, payment_number DESC
    """)
    
    members = execute_query("""
        SELECT member_id, farm_name, contact_phone 
        FROM members 
        ORDER BY farm_name
    """)
    
    documents = execute_query("""
        SELECT document_code, document_name 
        FROM internal_documents 
        ORDER BY document_code
    """)

    return template(
        'membership_fees.tpl',
        fees=fees,
        members=members,
        documents=documents,
        error=error,
        success=success
    )

@app.route('/membership_fees/update/<payment_number:int>', method=['GET', 'POST'])
@require_role('afh_accountant')
def update_fee(payment_number):

    error = None

    if request.method == 'POST':

        payment_status = request.forms.get('payment_status')
        payment_date = request.forms.get('payment_date')

        try:

            execute_query("""
                UPDATE membership_fees
                SET payment_status=%s,
                    payment_date=%s
                WHERE payment_number=%s
            """,(payment_status,payment_date,payment_number),fetch=False)

            redirect('/membership_fees')

        except Exception as e:
            error = str(e)

    fee = execute_query("""
        SELECT *
        FROM membership_fees
        WHERE payment_number=%s
    """,(payment_number,))

    return template(
        'edit_fee.tpl',
        fee=fee[0],
        error=error
    )


if __name__ == '__main__':
    run(app, host='0.0.0.0', port=8081, debug=True, reloader=True)