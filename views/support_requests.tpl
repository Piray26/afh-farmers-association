<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <title>Обращения участников</title>
    <link rel="stylesheet" href="/static/content/support_request.css">
    <link rel="stylesheet" href="/static/content/site.css">
</head>
<body>

<div class="navbar">
    <h2>📋 Обращения участников</h2>
    <a href="/dashboard" class="btn btn-secondary">Назад</a>
</div>

<div class="container">

    % if error:
        <div class="error">{{error}}</div>
    % end

    % if success:
        <div class="success">{{success}}</div>
    % end

    <div class="card">
        <h3>Список обращений</h3>
        <div class="table-scroll-container">
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Участник</th>
                        <th>Тема</th>
                        <th>Дата</th>
                        <th>Статус</th>
                    </tr>
                </thead>
                <tbody>
                    % for r in requests:
                    <tr>
                        <td>{{r['request_id']}}</td>
                        <td>{{r['member_id']}}</td>
                        <td>{{r['subject']}}</td>
                        <td>{{r['request_date']}}</td>
                        <td>{{r['processing_status']}}</td>
                    </tr>
                    % end
                </tbody>
            </table>
        </div>
    </div>

    <div class="card">
        <h3>Изменить статус обращения</h3>
        <form method="post" class="status-form">
            <label>
                ID обращения
                <input type="number" name="request_id" placeholder="Введите ID" required>
            </label>

            <label>
                Новый статус
                <select name="status">
                    <option value="Новое">Новое</option>
                    <option value="В работе">В работе</option>
                    <option value="Закрыто">Закрыто</option>
                </select>
            </label>

            <button type="submit" class="btn">Обновить статус</button>
        </form>
    </div>

</div>

</body>
</html>