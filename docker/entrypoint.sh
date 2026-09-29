#!/bin/bash

if [ -z "$DL_CONFIG_FILE" ]; then
    echo "Configuration file not set. Set up using environment variable DL_CONFIG_FILE."
    exit 1
fi

if [ -n "$TZ" -a -e "/usr/share/zoneinfo/$TZ" ]; then
    rm -f /etc/localtime
    ln -s "/usr/share/zoneinfo/$TZ" /etc/localtime
    echo "$TZ" > /etc/timezone
    echo "Timezone is set to $TZ"
fi

printenv | grep -E "^PATH" >> /etc/environment
printenv | grep -E "^DL_" >> /etc/environment

service cron start

dl_cmd=("/usr/local/bin/idea-plugin-downloader --config-file" "$(printf '%q' "$DL_CONFIG_FILE")")

if [ -n "$DL_LOG_PATH" ]; then
    dl_cmd=(${dl_cmd[@]} "--log-path" "$(printf '%q' "$DL_LOG_PATH")")
fi

if [ -n "$DL_PID_FILE" -a -z "$DL_CRON" ]; then
    dl_cmd=(${dl_cmd[@]} "--pid-file" "$(printf '%q' "$DL_PID_FILE")")
fi

if [ -z "$DL_CRON" ]; then
    eval ${dl_cmd[@]}
    exit 0
fi

dl_cmd=(${dl_cmd[@]} "--cron" "$(printf '%q' "$DL_CRON")" "&")
eval ${dl_cmd[@]}

tail -f /dev/null
