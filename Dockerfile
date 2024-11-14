# Use the Python 3.11.0b1-buster base image
FROM python:3.11.0b1-buster

# Set the working directory
WORKDIR /app

# Install dependencies for psycopg2 without specifying versions
RUN apt-get update && \
    apt-get install --no-install-recommends -y dnsutils libpq-dev python3-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set environment variables in the recommended format
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install pip and project dependencies
RUN python -m pip install --no-cache-dir pip==22.0.4
COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy project files
COPY . /app/

# Expose the application port
EXPOSE 8000

# Run database migrations
RUN python3 /app/manage.py migrate

# Set the working directory to the pygoat folder
WORKDIR /app/pygoat/

# Start the application with gunicorn
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "6", "pygoat.wsgi"]
