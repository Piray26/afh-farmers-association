<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <title>Обращения</title>

    <link rel="stylesheet" href="/static/content/site.css">
</head>
<body>

    <div class="navbar">
        <h2>📞 Обращения</h2>

        <a href="/dashboard" class="btn btn-secondary">
            Назад
        </a>
    </div>

    <div class="container">

        <div class="card">

            % if error:
                <div class="error">
                    {{error}}
                </div>
            % end

            % if success:
                <div class="success">
                    {{success}}
                </div>
            % end

            <form method="post">

                <label>
                    ID фермера
                    <input type="number" name="member_id" required>
                </label>

                <label>
                    Тема
                    <input
                        type="text"
                        name="subject"
                        maxlength="200"
                        required
                    >
                </label>

                <label>
                    Текст обращения
                    <textarea
                        name="text"
                        rows="6"
                        required
                    ></textarea>
                </label>

                <button type="submit" class="btn">
                    Создать обращение
                </button>

            </form>

        </div>

    </div>

</body>
</html>