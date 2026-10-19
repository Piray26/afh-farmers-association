<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <title>Отгрузка продукции</title>

    <link rel="stylesheet" href="/static/content/site.css">
</head>
<body>

<div class="navbar">
    <h2>🚚 Отгрузка продукции</h2>

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
                <th>Количество</th>
                <th>Дата</th>
                <th>Статус</th>
                <th>Примечание</th>
            </tr>

            % for s in shipments:
            <tr>
                <td>{{s['shipment_id']}}</td>
                <td>{{s['purchase_code']}}</td>
                <td>{{s['member_id']}}</td>
                <td>{{s['product_code']}}</td>
                <td>{{s['quantity']}}</td>
                <td>{{s['shipment_date']}}</td>
                <td>{{s['status']}}</td>
                <td>{{s['note']}}</td>
            </tr>
            % end

        </table>

    </div>

</div>

</body>
</html>
