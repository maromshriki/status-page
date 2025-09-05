FROM python:3.10.4
WORKDIR /app
COPY . /app
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install gunicorn
EXPOSE 8000
CMD ["python3", "statuspage/manage.py", "runserver", "0.0.0.0:8000", "--insecure"]

