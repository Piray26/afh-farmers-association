<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <title>Участники закупок</title>

    <link rel="stylesheet" href="/static/content/site.css">
</head>
<body>

<div class="navbar">
    <h2>👨‍🌾 Участники закупок</h2>

    <a href="/dashboard" class="btn btn-secondary">
        Назад
    </a>
</div>

<div class="container">

    <div class="card">

        <table>
            <tr>
                <th>ID</th>
                <th>Закупка</th>
                <th>Участник</th>
                <th>Продукт</th>
                <th>Заказано</th>
                <th>Фактически</th>
                <th>Цена</th>
                <th>Оплата</th>
            </tr>

            % for p in participants:
            <tr>
                <td>{{p['record_id']}}</td>
                <td>{{p['purchase_code']}}</td>
                <td>{{p['member_id']}}</td>
                <td>{{p['product_code']}}</td>
                <td>{{p['ordered_quantity']}}</td>
                <td>{{p['actual_quantity']}}</td>
                <td>{{p['agreed_price']}}</td>
                <td>{{p['payment_status']}}</td>
            </tr>
            % end

        </table>

    </div>

</div>

</body>
</html>
