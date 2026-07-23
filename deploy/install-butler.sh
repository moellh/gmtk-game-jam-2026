#!/bin/sh
set -eu

if command -v butler >/dev/null 2>&1; then
    echo "butler is already installed."
    exit 0
fi

if [ "$(id -u)" -ne 0 ]; then
    echo "Run this installer with sudo." >&2
    exit 1
fi

for command in curl unzip; do
    if ! command -v "$command" >/dev/null 2>&1; then
        echo "$command is required to install butler." >&2
        exit 1
    fi
done

install_dir=$(mktemp -d)
trap 'rm -rf "$install_dir"' EXIT HUP INT TERM

curl -fsSL \
    https://broth.itch.zone/butler/linux-amd64/LATEST/archive/default \
    -o "$install_dir/butler.zip"
unzip -q "$install_dir/butler.zip" -d "$install_dir/archive"
install -m 0755 "$install_dir/archive/butler" /usr/local/bin/butler

echo "Installed butler at /usr/local/bin/butler."
