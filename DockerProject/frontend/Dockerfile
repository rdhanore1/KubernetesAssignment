# frontend/Dockerfile - Flask
FROM python:3.11-slim

WORKDIR /app

# install dependencies
COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# copy all source code
COPY . /app/

ENV FLASK_ENV=production
ENV PORT=5000

EXPOSE 5000

# If your entry is app.py and flask app variable is `app`
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app", "--workers", "2"]