# Define base image
FROM python:3.14-slim

# 1. Install system-wide dependencies as root
ENV PIP_ROOT_USER_ACTION=ignore

WORKDIR /app

# Install runtime deps
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 2. Create non-root user and set permissions
RUN useradd -m -u 1000 appuser \
 && chown -R appuser:appuser /app

# 3. Copy application code as appuser
USER appuser
COPY --chown=appuser:appuser src/ ./src

# 4. Expose port and run gunicorn as appuser
EXPOSE 5000
CMD ["gunicorn", "-b", "0.0.0.0:5000", "src.app:app"]
