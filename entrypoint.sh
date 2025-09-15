#!/bin/bash
set -e

echo "===> מריץ מיגרציות"
python manage.py migrate --noinput

echo "===> אוסף סטטיים"
python manage.py collectstatic --noinput

echo "===> יוצר סופר יוזר msdw/msdw123 אם לא קיים"
python manage.py shell << END
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(username="msdw").exists():
    User.objects.create_superuser("msdw", "msdw@example.com", "msdw123")
    print("נוצר משתמש msdw עם סיסמה msdw123")
else:
    print("המשתמש msdw כבר קיים")
END

echo "===> מפעיל Gunicorn"
exec gunicorn statuspage.wsgi:application --bind 0.0.0.0:8000 --workers 5

