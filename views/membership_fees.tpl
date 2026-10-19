<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <title>Членские взносы</title>
    <link rel="stylesheet" href="/static/content/membership_fees.css">
    <link rel="stylesheet" href="/static/content/site.css">
</head>
<body>

<div class="navbar">
    <h2>💰 Членские взносы</h2>
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

        <h3 id="form_title">Новый взнос</h3>
        <form method="post" id="fee_form">
            <input type="hidden" name="action" id="form_action" value="add">
            <input type="hidden" name="original_payment_number" id="original_payment_number" value="">

            <div class="form-grid">
                <label>Участник (Фермер)
                    <div class="product-selector">
                        <input type="text" id="member_id" name="member_id" placeholder="Выберите участника" readonly required>
                        <button type="button" class="btn" onclick="openMemberModal()">Выбрать</button>
                    </div>
                </label>

                <label>Отчетный год
                    <input type="number" id="reporting_year" name="reporting_year" placeholder="2024" required>
                </label>

                <label>Сумма
                    <input type="number" step="0.01" id="amount" name="amount" placeholder="0.00" required>
                </label>

                <label>Дата оплаты
                    <input type="date" id="payment_date" name="payment_date">
                </label>

                <label>Статус
                    <select id="payment_status" name="payment_status">
                        <option value="Ожидает оплаты">Ожидает оплаты</option>
                        <option value="Частично оплачено">Частично оплачено</option>
                        <option value="Оплачено">Оплачено</option>
                    </select>
                </label>

                <label>Документ-основание
                    <div class="product-selector">
                        <input type="text" id="basis_document_code" name="basis_document_code" placeholder="Выберите документ" readonly required>
                        <button type="button" class="btn" onclick="openDocumentModal()">Выбрать</button>
                    </div>
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
                <th>№</th>
                <th>Участник (ID)</th>
                <th>Год</th>
                <th>Сумма</th>
                <th>Дата оплаты</th>
                <th>Статус</th>
                <th>Документ</th>
                <th>Действия</th>
            </tr>

            % for f in fees:
            <tr>
                <td>{{f['payment_number']}}</td>
                <td>{{f['member_id']}}</td>
                <td>{{f['reporting_year']}}</td>
                <td>{{f['amount']}}</td>
                <td>{{f['payment_date']}}</td>
                <td>{{f['payment_status']}}</td>
                <td>{{f['basis_document_code']}}</td>
                <td>
                    <button type="button" class="btn" onclick="editFee(
                        {{f['payment_number']}},
                        {{f['member_id']}},
                        {{f['reporting_year']}},
                        {{f['amount']}},
                        '{{f['payment_date']}}',
                        '{{f['payment_status']}}',
                        '{{f['basis_document_code']}}'
                    )">Изменить</button>
                </td>
            </tr>
            % end

        </table>
    </div>
</div>

<div id="memberModal" class="modal">
    <div class="modal-content">
        <span class="close" onclick="closeMemberModal()">&times;</span>
        <h3>Выбор участника</h3>
        <table class="data-table">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Название фермы</th>
                    <th>Телефон</th>
                    <th>Выбор</th>
                </tr>
            </thead>
            <tbody>
                % for m in members:
                <tr>
                    <td>{{m['member_id']}}</td>
                    <td>{{m['farm_name']}}</td>
                    <td>{{m['contact_phone']}}</td>
                    <td>
                        <button type="button" class="btn" onclick="selectMember('{{m['member_id']}}', '{{m['farm_name']}}')">
                            Выбрать
                        </button>
                    </td>
                </tr>
                % end
            </tbody>
        </table>
    </div>
</div>

<div id="documentModal" class="modal">
    <div class="modal-content">
        <span class="close" onclick="closeDocumentModal()">&times;</span>
        <h3>Выбор документа</h3>
        <table class="data-table">
            <thead>
                <tr>
                    <th>Код</th>
                    <th>Название</th>
                    <th>Выбор</th>
                </tr>
            </thead>
            <tbody>
                % for d in documents:
                <tr>
                    <td>{{d['document_code']}}</td>
                    <td>{{d['document_name']}}</td>
                    <td>
                        <button type="button" class="btn" onclick="selectDocument('{{d['document_code']}}', '{{d['document_name']}}')">
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
    function openMemberModal() { document.getElementById("memberModal").style.display = "block"; }
    function closeMemberModal() { document.getElementById("memberModal").style.display = "none"; }
    
    function selectMember(id, name) { 
        document.getElementById("member_id").value = id; 
        closeMemberModal(); 
    }

    function openDocumentModal() { document.getElementById("documentModal").style.display = "block"; }
    function closeDocumentModal() { document.getElementById("documentModal").style.display = "none"; }
    
    function selectDocument(code, name) { 
        document.getElementById("basis_document_code").value = code; 
        closeDocumentModal(); 
    }

    window.onclick = function(e) {
        if (e.target == document.getElementById("memberModal")) closeMemberModal();
        if (e.target == document.getElementById("documentModal")) closeDocumentModal();
    };

    function editFee(number, memberId, year, amount, date, status, docCode) {
        document.getElementById('original_payment_number').value = number;
        document.getElementById('member_id').value = memberId;
        document.getElementById('reporting_year').value = year;
        document.getElementById('amount').value = amount;
        document.getElementById('payment_date').value = date;
        document.getElementById('payment_status').value = status;
        document.getElementById('basis_document_code').value = docCode;

        document.getElementById('form_action').value = 'edit';
        document.getElementById('submit_btn').textContent = ' Обновить';
        document.getElementById('cancel_btn').style.display = 'inline-block';
        document.getElementById('form_title').textContent = 'Редактирование взноса №' + number;
        
        document.getElementById('fee_form').scrollIntoView({ behavior: 'smooth' });
    }

    function resetForm() {
        document.getElementById('fee_form').reset();
        document.getElementById('form_action').value = 'add';
        document.getElementById('original_payment_number').value = '';
        document.getElementById('submit_btn').textContent = 'Создать';
        document.getElementById('cancel_btn').style.display = 'none';
        document.getElementById('form_title').textContent = 'Новый взнос';
    }
</script>

</body>
</html>