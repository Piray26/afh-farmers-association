<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <title>АФХ — Вход</title>
    <link rel="stylesheet" href="/static/content/login.css">
    <link rel="stylesheet" href="/static/content/site.css">
</head>
<body class="login-page">

    <div class="login-wrapper">
        <div class="login-container">
            
            <div class="login-header">
                <span class="login-logo"></span>
                <h1 class="login-title">Ассоциация фермерских хозяйств</h1>
                <p class="login-subtitle">Вход в информационную систему</p>
            </div>

            <div class="login-body">

                % if error:
                    <div class="error-message">
                        {{error}}
                    </div>
                % end

                <form method="post">

                    <div class="form-field">
                        <label for="role_name">Роль пользователя</label>
                        <select name="role_name" id="role_name" required>
                            <option value="afh_member">Фермер</option>
                            <option value="afh_accountant">Бухгалтер</option>
                            <option value="afh_support_manager">Специалист поддержки</option>
                            <option value="afh_purchase_manager">Менеджер закупок</option>
                        </select>
                    </div>

                    <div class="form-field">
                        <label for="password">Пароль</label>
                        <input 
                            type="password" 
                            name="password" 
                            id="password" 
                            placeholder="Введите пароль"
                            required
                        >
                    </div>

                    <button type="submit" class="login-button">
                        Войти в систему
                    </button>

                </form>

            </div>

        </div>
    </div>

</body>
</html>