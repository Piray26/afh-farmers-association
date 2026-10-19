<head>
    <meta charset="UTF-8">
    <title>Панель управления</title>
    <link rel="stylesheet" href="/static/content/site.css">
</head>

<div class="navbar">
        <h2>Панель управления</h2>

        <a href="/login" class="btn btn-secondary">
            Назад
        </a>
    </div>

<div class="cards">

% if role == 'afh_member':

    <div class="menu-card">
        <h3>🌾 Учёт продукции</h3>
        <p>Регистрация произведённой продукции.</p>
        <a href="/production" class="btn">Открыть</a>
    </div>

    <div class="menu-card">
        <h3>🛒 Совместные закупки</h3>
        <p>Участие в коллективных закупках.</p>
        <a href="/purchases" class="btn">Открыть</a>
    </div>

    <div class="menu-card">
        <h3>📞 Обращения</h3>
        <p>Связь с региональным отделением.</p>
        <a href="/support" class="btn">Открыть</a>
    </div>

% end


% if role == 'afh_accountant':

    <div class="menu-card">
        <h3>💰 Членские взносы</h3>
        <p>Учёт и контроль оплат.</p>
        <a href="/membership_fees" class="btn">Открыть</a>
    </div>

% end


% if role == 'afh_support_manager':

    <div class="menu-card">
        <h3>📞 Обращения</h3>
        <p>Просмотр и обработка обращений.</p>
        <a href="/support_requests" class="btn">Открыть</a>
    </div>

    <div class="menu-card">
        <h3>🏢 Справочники</h3>
        <p>Отделения, сотрудники и участники.</p>
        <a href="/reference_data" class="btn">Открыть</a>
    </div>

% end


% if role == 'afh_purchase_manager':

    <div class="menu-card">
        <h3>📦 Коллективные закупки</h3>

        <p>
            Создание закупок, назначение поставщиков,
            изменение статусов и контроль проведения закупок.
        </p>

        <a href="/collective_purchases" class="btn">
            Открыть
        </a>
    </div>

% end

</div>