import psycopg2
from psycopg2 import sql
from psycopg2.extras import RealDictCursor
from dotenv import load_dotenv
from os import environ

load_dotenv()


def get_conn():
    return psycopg2.connect(
        host=environ.get("DB_HOST"),
        database=environ.get("DB_NAME"),
        user=environ.get("DB_USER"),
        password=environ.get("DB_PASSWORD"),
        port=5432,
        cursor_factory=RealDictCursor)


def get_cat_id(cat_name):
    conn = get_conn()
    query = sql.SQL("""
    SELECT category_id
    FROM categories
    WHERE category_name = %s
    """)

    with conn.cursor() as cur:
        cur.execute(query, (cat_name,))
        row = cur.fetchone()
        print(row)
    conn.close()
    if not row:
        raise ValueError("Category not found")
    if row.get('category_id') is None:
        raise ValueError("Category ID not found")
    return row['category_id']


def get_tickets():
    conn = get_conn()
    query = sql.SQL("""
    SELECT *
    FROM tickets
    """)
    with conn.cursor() as cur:
        cur.execute(query)
        rows = cur.fetchall()
    conn.close()
    return rows


def insert_ticket(cat_name, ticket_text, responsible_person, created_at):
    conn = get_conn()
    query = sql.SQL("""
    INSERT INTO tickets
    (category_id, ticket_text, responsible_person, created_at)
    VALUES (%s, %s, %s, %s)
    """)

    try:
        cat_id = get_cat_id(cat_name)
        with conn.cursor() as cur:
            cur.execute(query, (cat_id, ticket_text,
                        responsible_person, created_at))
            conn.commit()
    except Exception as e:
        conn.rollback()
        print(e)
    finally:
        conn.close()


def get_subjects():
    conn = get_conn()
    query = sql.SQL("""
    SELECT category_name
    FROM categories
    """)
    with conn.cursor() as cur:
        cur.execute(query)
        rows = cur.fetchall()
    conn.close()
    return [row['category_name'] for row in rows]


if __name__ == '__main__':
    print(get_subjects())
