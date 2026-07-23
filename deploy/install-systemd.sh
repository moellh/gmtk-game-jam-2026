#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
service_user=${SERVICE_USER:-${SUDO_USER:-$(id -un)}}
service_group=${SERVICE_GROUP:-$(id -gn "$service_user")}
unit_dir=/etc/systemd/system

if [ "$(id -u)" -ne 0 ]; then
    echo "Run this installer with sudo (the service itself will run as $service_user)." >&2
    exit 1
fi

sed \
    -e "s|@REPO_DIR@|$repo_dir|g" \
    -e "s|@SERVICE_USER@|$service_user|g" \
    -e "s|@SERVICE_GROUP@|$service_group|g" \
    "$repo_dir/deploy/systemd/gmtk-jam-update.service.in" \
    > "$unit_dir/gmtk-jam-update.service"
install -m 0644 "$repo_dir/deploy/systemd/gmtk-jam-update.timer" "$unit_dir/gmtk-jam-update.timer"

mkdir -p "$repo_dir/deploy/state"
chown -R "$service_user:$service_group" "$repo_dir/deploy/state"

"$repo_dir/deploy/install-butler.sh"
docker compose -f "$repo_dir/deploy/docker-compose.yml" --profile build build builder
docker compose -f "$repo_dir/deploy/docker-compose.yml" up -d web

systemctl daemon-reload
systemctl enable --now gmtk-jam-update.timer
systemctl start gmtk-jam-update.service

echo "Installed. Reverse proxy to gmtk-jam-web:80 on Docker network app-net."
