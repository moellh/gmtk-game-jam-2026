#!/bin/sh
set -eu

commit="${1:-}"
output_dir="${2:-}"

case "$commit" in
    ''|*[!0-9a-f]*)
        echo "Invalid commit: $commit" >&2
        exit 2
        ;;
esac

case "$output_dir" in
    /state/work/*/export) ;;
    *)
        echo "Output must be below /state/work and end in /export" >&2
        exit 2
        ;;
esac

project_dir="/tmp/project-$commit"
rm -rf "$project_dir"
mkdir -p "$project_dir" "$output_dir"

git -c safe.directory=/repo -C /repo archive "$commit" | tar -x -C "$project_dir"

godot --headless --path "$project_dir" --export-release Web "$output_dir/index.html"
