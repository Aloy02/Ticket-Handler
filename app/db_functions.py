import psycopg2
from psycopg2 import sql
from psycopg2.extras import RealDictCursor


def get_conn():
    return psycopg2.connect("dbname=tickets host='localhost'", cursor_factory=RealDictCursor)


def get_subjects():
    conn = get_conn()
    query = sql.SQL("""
    SELECT cat_name
    FROM categories
    """)
    with conn.cursor() as cur:
        cur.execute(query)
        rows = cur.fetchall()
    conn.close()
    return [row['cat_name'] for row in rows]


if __name__ == '__main__':
    print(get_subjects())
