<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <title>Учёт продукции</title>

    <link rel="stylesheet" href="/static/content/site.css">
</head>

<body>

    <div class="navbar">

        <h2>🌾 Учёт продукции</h2>

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

                    <input
                        type="number"
                        name="member_id"
                        required
                    >
                </label>

                <label>
                    Продукция

                    <div class="product-selector">

                        <input
                            type="text"
                            id="product_code"
                            name="product_code"
                            placeholder="Выберите продукцию"
                            readonly
                            required
                        >

                        <button
                            type="button"
                            class="btn"
                            onclick="openProductModal()"
                        >
                            Выбрать
                        </button>

                    </div>
                </label>

                <label>
                    Количество

                    <input
                        type="number"
                        step="0.001"
                        min="0.001"
                        name="quantity"
                        required
                    >
                </label>

                <button
                    type="submit"
                    class="btn"
                >
                    Добавить запись
                </button>

            </form>

        </div>

    </div>

    <!-- Модальное окно -->

    <div id="productModal" class="modal">

        <div class="modal-content">

            <span
                class="close"
                onclick="closeProductModal()"
            >
                &times;
            </span>

            <h3>
                Справочник продукции
            </h3>

            <table class="data-table">

                <thead>

                    <tr>
                        <th>Код</th>
                        <th>Наименование</th>
                        <th>Ед. изм.</th>
                        <th>Выбор</th>
                    </tr>

                </thead>

                <tbody>

                    % for product in products:

                    <tr>

                        <td>
                            {{product['product_code']}}
                        </td>

                        <td>
                            {{product['product_name']}}
                        </td>

                        <td>
                            {{product['unit_of_measure']}}
                        </td>

                        <td>

                            <button
                                type="button"
                                class="btn"
                                onclick="selectProduct(
                                    '{{product['product_code']}}',
                                    '{{product['product_name']}}'
                                )"
                            >
                                Выбрать
                            </button>

                        </td>

                    </tr>

                    % end

                </tbody>

            </table>

        </div>

    </div>

    <script>

        function openProductModal() {

            document.getElementById(
                "productModal"
            ).style.display = "block";
        }

        function closeProductModal() {

            document.getElementById(
                "productModal"
            ).style.display = "none";
        }

        function selectProduct(
            productCode,
            productName
        ) {

            document.getElementById(
                "product_code"
            ).value =
                productCode + " - " + productName;

            document.getElementById(
                "product_code"
            ).setAttribute(
                "data-code",
                productCode
            );

            document.getElementById(
                "product_code"
            ).value = productCode;

            closeProductModal();
        }

        window.onclick = function(event) {

            const modal =
                document.getElementById(
                    "productModal"
                );

            if (event.target === modal) {

                closeProductModal();
            }
        };

    </script>

</body>
</html>