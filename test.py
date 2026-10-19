import psycopg2

conn = psycopg2.connect(
    host="localhost",
    database="afh",
    user="postgres",
    password="Sliva005"
)

cur = conn.cursor()

tables = [
    'collective_purchases',
    'purchase_participation',
    'product_types',
    'members',
    'farm_resource_receipts',
    'product_shipments',
    'farm_products'
]

for table in tables:

    print("\n" + "=" * 80)
    print(f"TABLE: {table}")
    print("=" * 80)

    cur.execute("""
        SELECT
            column_name,
            data_type,
            is_nullable
        FROM information_schema.columns
        WHERE table_name=%s
        ORDER BY ordinal_position
    """, (table,))

    for row in cur.fetchall():
        print(row)

    print("\nFOREIGN KEYS:")

    cur.execute("""
        SELECT
            kcu.column_name,
            ccu.table_name,
            ccu.column_name
        FROM information_schema.table_constraints tc
        JOIN information_schema.key_column_usage kcu
            ON tc.constraint_name = kcu.constraint_name
        JOIN information_schema.constraint_column_usage ccu
            ON ccu.constraint_name = tc.constraint_name
        WHERE tc.constraint_type='FOREIGN KEY'
          AND tc.table_name=%s
    """, (table,))

    for row in cur.fetchall():
        print(row)

cur.close()
conn.close()
