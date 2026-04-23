#!/bin/sh

echo "Waiting for database..."
while ! python -c "
import os, psycopg2
conn = psycopg2.connect(
    dbname=os.getenv('POSTGRES_DB'),
    user=os.getenv('POSTGRES_USER'),
    password=os.getenv('POSTGRES_PASSWORD'),
    host=os.getenv('DB_HOST'),
    port=os.getenv('DB_PORT')
)
conn.close()
" 2>/dev/null; do
  sleep 1
done
echo "Database is ready!"

python manage.py migrate
python manage.py collectstatic --noinput
cp -r /app/collected_static/. /backend_static/static/

gunicorn --bind 0.0.0.0:8000 kittygram_backend.wsgi
