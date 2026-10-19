FROM python:3.12-slim as builder

ARG lab_login
ARG lab_token

RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

WORKDIR /opt/app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt


FROM python:3.12-slim as runtime

ARG lab_login
ARG lab_token

LABEL org.lab.login=$lab_login \
      org.lab.token=$lab_token

RUN groupadd -r appgroup && useradd -r -g appgroup -m -s /bin/false appuser

COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
WORKDIR /opt/app

COPY app ./app

RUN chown -R appuser:appgroup /opt/app
USER appuser

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD python -c "import urllib.request,sys; sys.exit(0) if urllib.request.urlopen('http://localhost:8000/health').status==200 else sys.exit(1)"

CMD ["gunicorn", "--bind", "0.0.0.0:8000", \
     "--workers", "2", "--threads", "4", \
     "--graceful-timeout", "30", \
     "--worker-tmp-dir", "/dev/shm", \
     "--access-logfile", "-", "--error-logfile", "-", \
     "app.app:app"]