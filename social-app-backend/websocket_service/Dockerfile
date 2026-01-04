FROM python:3.11-slim

WORKDIR /app

# Install Python dependencies
RUN pip install --upgrade pip
COPY requirements.txt .
RUN pip install --no-cache-dir --timeout 300 -r requirements.txt

# Copy application
COPY . .

EXPOSE 8002

CMD ["python", "server.py"]
