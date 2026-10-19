<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <title>Коллективные закупки</title>
    <link rel="stylesheet" href="/static/content/site.css">
    <style>
        .form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 15px; margin-bottom: 20px; }
        .form-grid label { display: flex; flex-direction: column; gap: 5px; }
        .full-width { grid-column: span 2; }
        .btn-group { display: flex; gap: 10px; margin-top: 10px; }
    </style>
</head>
<body>

<div class="navbar">
    <h2>📦 Коллективные закупки</h2>
    <a href="/dashboard" class="btn btn-secondary">Назад</a>
</div>

<div class="container">
    <div class="card">

        % if error:
            <div class="error">{{error}}</div>
        % end

        % if success:
            <div class="success">{{success}}</div>
        % end

        <h3 id="form_title">Новая закупка</h3>
        <form method="post" id="purchase_form">
            <input type="hidden" name="action" id="form_action" value="add">
            <input type="hidden" name="original_purchase_code" id="original_purchase_code" value="">

            <div class="form-grid">
                <label>Код закупки
                    <input type="text" id="purchase_code" name="purchase_code" placeholder="Код закупки" required>
                </label>
                <label>Название
                    <input type="text" id="purchase_name" name="purchase_name" placeholder="Название" required>
                </label>
                
                <label>Поставщик
                    <div class="product-selector">
                        <input type="text" id="supplier_code" name="supplier_code" placeholder="Выберите поставщика" readonly required>
                        <button type="button" class="btn" onclick="openSupplierModal()">Выбрать</button>
                    </div>
                </label>
                <label>Отделение
                    <div class="product-selector">
                        <input type="text" id="responsible_branch" name="responsible_branch" placeholder="Выберите отделение" readonly required>
                        <button type="button" class="btn" onclick="openBranchModal()">Выбрать</button>
                    </div>
                </label>

                <label>Плановая дата
                    <input type="date" id="planned_date" name="planned_date" required>
                </label>
                <label>Статус
                    <select id="purchase_status" name="purchase_status">
                        <option value="Планируется">Планируется</option>
                        <option value="Открыта">Открыта</option>
                        <option value="Завершена">Завершена</option>
                        <option value="Отменена">Отменена</option>
                    </select>
                </label>
                <label>Тип закупки
                    <input type="text" id="purchase_type" name="purchase_type" placeholder="Тип закупки" required>
                </label>
                <label>Единица измерения
                    <input type="text" id="unit_of_measure" name="unit_of_measure" placeholder="шт., кг, л..." required>
                </label>
            </div>

            <div class="btn-group">
                <button type="submit" class="btn" id="submit_btn">Создать</button>
                <button type="button" class="btn btn-secondary" id="cancel_btn" style="display:none;" onclick="resetForm()">Отмена</button>
            </div>
        </form>

    </div>
</div>

<div class="container">
    <div class="card">
        <table>
            <tr>
                <th>Код</th>
                <th>Название</th>
                <th>Поставщик</th>
                <th>Отделение</th>
                <th>Дата</th>
                <th>Статус</th>
                <th>Тип</th>
                <th>Ед. изм.</th>
                <th>Действия</th>
            </tr>

            % for p in purchases:
            <tr>
                <td>{{p['purchase_code']}}</td>
                <td>{{p['purchase_name']}}</td>
                <td>{{p['supplier_code']}}</td>
                <td>{{p['responsible_branch']}}</td>
                <td>{{p['planned_date']}}</td>
                <td>{{p['purchase_status']}}</td>
                <td>{{p['purchase_type']}}</td>
                <td>{{p['unit_of_measure']}}</td>
                <td>
                    <button
                        type="button"
                        class="btn"
                        onclick="editPurchase(
                            '{{p['purchase_code']}}',
                            '{{p['purchase_name']}}',
                            '{{p['supplier_code']}}',
                            '{{p['responsible_branch']}}',
                            '{{p['planned_date']}}',
                            '{{p['purchase_status']}}',
                            '{{p['purchase_type']}}',
                            '{{p['unit_of_measure']}}'
                        )"
                    >
                        Изменить
                    </button>
                </td>
            </tr>
            % end

        </table>
    </div>
</div>

<!-- Модальное окно выбора поставщика -->
<div id="supplierModal" class="modal">
    <div class="modal-content">
        <span class="close" onclick="closeSupplierModal()">&times;</span>
        <h3>Выбор поставщика</h3>

        <table class="data-table">
            <thead>
                <tr>
                    <th>Код</th>
                    <th>Наименование</th>
                    <th>Выбор</th>
                </tr>
            </thead>
            <tbody>
                % for s in suppliers:
                <tr>
                    <td>{{s['counterparty_code']}}</td>
                    <td>{{s['organization_name']}}</td>
                    <td>
                        <button type="button" class="btn" onclick="selectSupplier('{{s['counterparty_code']}}', '{{s['organization_name']}}')">
                            Выбрать
                        </button>
                    </td>
                </tr>
                % end
            </tbody>
        </table>
    </div>
</div>

<!-- Модальное окно выбора отделения -->
<div id="branchModal" class="modal">
    <div class="modal-content">
        <span class="close" onclick="closeBranchModal()">&times;</span>
        <h3>Выбор отделения</h3>

        <table class="data-table">
            <thead>
                <tr>
                    <th>Код</th>
                    <th>Наименование</th>
                    <th>Выбор</th>
                </tr>
            </thead>
            <tbody>
                % for b in branches:
                <tr>
                    <td>{{b['branch_code']}}</td>
                    <td>{{b['branch_name']}}</td>
                    <td>
                        <button type="button" class="btn" onclick="selectBranch('{{b['branch_code']}}', '{{b['branch_name']}}')">
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
    // === Модальные окна ===
    function openSupplierModal() { document.getElementById("supplierModal").style.display = "block"; }
    function closeSupplierModal() { document.getElementById("supplierModal").style.display = "none"; }
    function selectSupplier(code, name) { document.getElementById("supplier_code").value = code; closeSupplierModal(); }

    function openBranchModal() { document.getElementById("branchModal").style.display = "block"; }
    function closeBranchModal() { document.getElementById("branchModal").style.display = "none"; }
    function selectBranch(code, name) { document.getElementById("responsible_branch").value = code; closeBranchModal(); }

    window.onclick = function(e) {
        if (e.target == document.getElementById("supplierModal")) closeSupplierModal();
        if (e.target == document.getElementById("branchModal")) closeBranchModal();
    };

    // === Редактирование ===
    function editPurchase(code, name, supplier, branch, date, status, type, unit) {
        document.getElementById('purchase_code').value = code;
        document.getElementById('original_purchase_code').value = code;
        document.getElementById('purchase_name').value = name;
        document.getElementById('supplier_code').value = supplier;
        document.getElementById('responsible_branch').value = branch;
        document.getElementById('planned_date').value = date;
        document.getElementById('purchase_status').value = status;
        document.getElementById('purchase_type').value = type;
        document.getElementById('unit_of_measure').value = unit || '';

        document.getElementById('form_action').value = 'edit';
        document.getElementById('submit_btn').textContent = '💾 Обновить';
        document.getElementById('cancel_btn').style.display = 'inline-block';
        document.getElementById('form_title').textContent = 'Редактирование закупки';
        
        document.getElementById('purchase_form').scrollIntoView({ behavior: 'smooth' });
    }

    function resetForm() {
        document.getElementById('purchase_form').reset();
        document.getElementById('form_action').value = 'add';
        document.getElementById('original_purchase_code').value = '';
        document.getElementById('submit_btn').textContent = 'Создать';
        document.getElementById('cancel_btn').style.display = 'none';
        document.getElementById('form_title').textContent = 'Новая закупка';
    }
</script>

</body>
</html>