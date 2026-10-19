<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <title>Совместные закупки</title>
    <link rel="stylesheet" href="/static/content/site.css">
</head>
<body>

    <div class="navbar">
        <h2>🛒 Совместные закупки</h2>
        <a href="/dashboard" class="btn btn-secondary">Назад</a>
    </div>

    <div class="container">

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

        <div class="card">
            <h3>Подать заявку на участие</h3>

            <form method="post">

                <label>
                    ID фермера
                    <input type="number" name="member_id" required>
                </label>

                <label>
                    Код закупки
                    <div class="product-selector">
                        <input
                            type="text"
                            id="purchase_code"
                            name="purchase_code"
                            placeholder="Выберите закупку"
                            readonly
                            required
                        >
                        <button
                            type="button"
                            class="btn"
                            onclick="openPurchaseModal()"
                        >
                            Выбрать
                        </button>
                    </div>
                </label>

                <label>
                    Количество
                    <input
                        type="number"
                        step="0.01"
                        name="ordered_qty"
                        required
                    >
                </label>

                <button type="submit" class="btn">
                    Отправить заявку
                </button>

            </form>
        </div>

    </div>

    <div id="purchaseModal" class="modal">
        <div class="modal-content">
            <span class="close" onclick="closePurchaseModal()">&times;</span>
            <h3>Доступные закупки</h3>

            <table class="data-table">
                <thead>
                    <tr>
                        <th>Код</th>
                        <th>Название</th>
                        <th>Поставщик</th>
                        <th>Плановая дата</th>
                        <th>Статус</th>
                        <th>Ед. изм.</th>
                        <th>Выбор</th>
                    </tr>
                </thead>
                <tbody>
                    % for p in purchases:
                        % if p['purchase_status'] == 'Планируется':
                        <tr>
                            <td>{{p['purchase_code']}}</td>
                            <td>{{p['purchase_name']}}</td>
                            <td>{{p['supplier_name']}}</td>
                            <td>{{p['planned_date']}}</td>
                            <td>{{p['purchase_status']}}</td>
                            <td>{{p['unit_of_measure']}}</td>
                            <td>
                                <button
                                    type="button"
                                    class="btn"
                                    onclick="selectPurchase(
                                        '{{p['purchase_code']}}',
                                        '{{p['purchase_name']}}'
                                    )"
                                >
                                    Выбрать
                                </button>
                            </td>
                        </tr>
                        % end
                    % end
                </tbody>
            </table>
        </div>
    </div>

    <script>
        function openPurchaseModal() {
            document.getElementById("purchaseModal").style.display = "block";
        }

        function closePurchaseModal() {
            document.getElementById("purchaseModal").style.display = "none";
        }

        function selectPurchase(purchaseCode, purchaseName) {
            document.getElementById("purchase_code").value = purchaseCode;
            closePurchaseModal();
        }

        window.onclick = function(event) {
            const modal = document.getElementById("purchaseModal");
            if (event.target === modal) {
                closePurchaseModal();
            }
        };
    </script>

</body>
</html>