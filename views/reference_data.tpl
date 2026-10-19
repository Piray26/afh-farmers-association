<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <title>Справочники</title>

    <link rel="stylesheet" href="/static/content/site.css">
</head>
<body>

    <div class="navbar">
        <h2>🏢 Справочники</h2>

        <a href="/dashboard" class="btn btn-secondary">
            Назад
        </a>
    </div>

    <div class="container">

        <div class="card">

            <h3>Региональные отделения</h3>

            <table>
                <tr>
                    <th>Код</th>
                    <th>Название</th>
                    <th>Регион</th>
                    <th>Адрес</th>
                    <th>Телефон</th>
                </tr>

                % for b in branches:
                <tr>
                    <td>{{b['branch_code']}}</td>
                    <td>{{b['branch_name']}}</td>
                    <td>{{b['region_code']}}</td>
                    <td>{{b['office_address']}}</td>
                    <td>{{b['contact_phone']}}</td>
                </tr>
                % end

            </table>

        </div>

        <div class="card">

            <h3>Сотрудники</h3>

            <table>
                <tr>
                    <th>ID</th>
                    <th>Фамилия</th>
                    <th>Имя</th>
                    <th>Отчество</th>
                    <th>Отделение</th>
                    <th>Должность</th>
                    <th>Телефон</th>
                    <th>Email</th>
                </tr>

                % for e in employees:
                <tr>
                    <td>{{e['employee_id']}}</td>
                    <td>{{e['last_name']}}</td>
                    <td>{{e['first_name']}}</td>
                    <td>{{e['middle_name']}}</td>
                    <td>{{e['branch_code']}}</td>
                    <td>{{e['position']}}</td>
                    <td>{{e['contact_phone']}}</td>
                    <td>{{e['email']}}</td>
                </tr>
                % end

            </table>

        </div>

        <div class="card">

            <h3>Участники АФХ</h3>

            <table>
                <tr>
                    <th>ID</th>
                    <th>Хозяйство</th>
                    <th>Форма</th>
                    <th>ИНН</th>
                    <th>ОГРН</th>
                    <th>Дата вступления</th>
                    <th>Телефон</th>
                    <th>Email</th>
                    <th>Адрес</th>
                    <th>Отделение</th>
                </tr>

                % for m in members:
                <tr>
                    <td>{{m['member_id']}}</td>
                    <td>{{m['farm_name']}}</td>
                    <td>{{m['legal_form']}}</td>
                    <td>{{m['inn']}}</td>
                    <td>{{m['ogrn']}}</td>
                    <td>{{m['join_date']}}</td>
                    <td>{{m['contact_phone']}}</td>
                    <td>{{m['email']}}</td>
                    <td>{{m['farm_address']}}</td>
                    <td>{{m['branch_code']}}</td>
                </tr>
                % end

            </table>

        </div>

    </div>

</body>
</html>