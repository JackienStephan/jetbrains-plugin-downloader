FROM python:3.14-slim-trixie AS builder

ADD . /code

RUN pip install hatch && \
    cd /code && \
    hatch build

FROM python:3.14-slim-trixie

COPY --from=builder /code/dist /dist/
COPY config_docker.json /etc/downloader_config.json
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh

ENV DL_CONFIG_FILE="/etc/downloader_config.json"
ENV DL_LOG_PATH=""
ENV DL_CRON=""
ENV DL_PID_FILE=""

RUN apt-get update && \
    apt-get install -y curl cron procps && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir /dist/*.whl && \
    mkdir -p /data/files

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]