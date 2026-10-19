<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <title>{{title}}</title>

    <style>
        body {
            margin: 0;
            font-family: Segoe UI, Arial, sans-serif;
            background: #f4f6f9;
        }

        .navbar {
            background: #2c3e50;
            color: white;
            padding: 15px 30px;
        }

        .container {
            max-width: 1200px;
            margin: 30px auto;
            background: white;
            padding: 25px;
            border-radius: 10px;
            box-shadow: 0 3px 10px rgba(0,0,0,.1);
        }

        .btn {
            display: inline-block;
            padding: 10px 15px;
            background: #3498db;
            color: white;
            text-decoration: none;
            border-radius: 6px;
            border: none;
            cursor: pointer;
        }

        .btn:hover {
            background: #2980b9;
        }

        .error {
            background: #ffe6e6;
            color: #c0392b;
            padding: 12px;
            border-radius: 6px;
            margin-bottom: 15px;
        }

        .success {
            background: #e8fff0;
            color: #27ae60;
            padding: 12px;
            border-radius: 6px;
            margin-bottom: 15px;
        }

        table {
            width: 100%;
            border-collapse: collapse;
        }

        table th {
            background: #34495e;
            color: white;
            padding: 10px;
        }

        table td {
            padding: 10px;
            border-bottom: 1px solid #ddd;
        }
    </style>
</head>
<body>

<div class="navbar">
    Система АФХ
</div>

<div class="container">
    {{!base}}
</div>

</body>
</html>
