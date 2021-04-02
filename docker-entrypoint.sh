#!/usr/bin/env bash

# Either http or http-socket
export MODE=${MODE:-http}

exec uwsgi --${MODE} :8080 \
    --wsgi-file app.py \
    --callable app \
    --die-on-term \
    --need-app