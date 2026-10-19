import psycopg2
from psycopg2.extras import RealDictCursor

DB_CONFIG = {
    "dbname": "afh",
    "user": "postgres",
    "password": "Sliva005",
    "host": "localhost",
    "port": "5432"
}

def get_conn():
    return psycopg2.connect(**DB_CONFIG, cursor_factory=RealDictCursor)

def execute_query(query, params=None, fetch=True):
    conn = get_conn()

    try:
        cur = conn.cursor()
        if params:
            fixed_params = []

            for p in params:
                if isinstance(p, str):
                    p = fix_encoding(p)
                fixed_params.append(p)
            params = tuple(fixed_params)
        cur.execute(query, params or ())

        if fetch:
            result = cur.fetchall() if cur.description else []
            conn.commit()
            return result

        conn.commit()
        return True

    except KeyError as e:
        print(f"[KEYERROR] Ошибка доступа к ключу: {e}")
        raise

    except Exception as e:
        conn.rollback()
        print(f"[DB ERROR] {type(e).__name__}: {e}")
        raise

    finally:
        cur.close()
        conn.close()

def fix_encoding(value):

    if value is None:
        return value

    if not isinstance(value, str):
        return value

    try:
        return value.encode('latin1').decode('utf-8')
    except Exception:
        return value