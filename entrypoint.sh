#!/bin/sh

echo "Running database migrations..."
python3 statuspage/manage.py migrate --noinput

echo "Collecting static files..."
python3 statuspage/manage.py collectstatic --noinput

echo "Starting server..."
exec "$@"

