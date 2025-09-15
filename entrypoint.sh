#!/bin/bash
set -e

echo "===> מריץ מיגרציות"
python3 statuspage/manage.py migrate 

echo "===> אוסף סטטיים"
python3 statuspage/manage.py collectstatic --no-input


echo "===> מפעיל Gunicorn"
exec gunicorn statuspage.wsgi:application --bind 0.0.0.0:8000 --workers 5

