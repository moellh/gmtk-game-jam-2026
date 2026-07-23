#!/usr/bin/env python3
"""Fetch remote branches, build active commits, and atomically publish the site."""

from __future__ import annotations

import argparse
import datetime as dt
import fcntl
import html
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import time
from urllib.parse import quote


REPO = Path(__file__).resolve().parent.parent
DEPLOY = REPO / "deploy"
STATE = DEPLOY / "state"
CACHE = STATE / "cache"
WORK = STATE / "work"
WWW = STATE / "www"
COMPOSE = DEPLOY / "docker-compose.yml"
MAX_AGE_SECONDS = 48 * 60 * 60
FAILED_RETRY_SECONDS = 5 * 60
BUILDER_IMAGE = "gmtk-jam-builder:4.7.1"


class UpdateError(RuntimeError):
    pass


def run(*args: str, check: bool = True, capture: bool = True) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        args,
        cwd=REPO,
        check=check,
        text=True,
        stdout=subprocess.PIPE if capture else None,
        stderr=subprocess.PIPE if capture else None,
    )


def git(*args: str, check: bool = True) -> subprocess.CompletedProcess[str]:
    return run("git", *args, check=check)


def fetch() -> None:
    print("Fetching origin branches", flush=True)
    result = git(
        "fetch",
        "--prune",
        "--no-tags",
        "origin",
        "+refs/heads/*:refs/remotes/origin/*",
        check=False,
    )
    if result.returncode:
        raise UpdateError(result.stderr.strip() or "git fetch failed")


def remote_branches() -> dict[str, str]:
    result = git(
        "for-each-ref",
        "--format=%(refname:strip=3)\t%(objectname)",
        "refs/remotes/origin",
    )
    branches: dict[str, str] = {}
    for line in result.stdout.splitlines():
        name, commit = line.split("\t", 1)
        if name != "HEAD":
            branches[name] = commit
    return branches


def commit_time(commit: str) -> int:
    return int(git("show", "-s", "--format=%ct", commit).stdout.strip())


def commit_details(commit: str) -> dict[str, str | int]:
    result = git("show", "-s", "--format=%ct%x00%an%x00%s", commit).stdout.rstrip("\n")
    timestamp, author, subject = result.split("\0", 2)
    committed_at = dt.datetime.fromtimestamp(int(timestamp), dt.timezone.utc).isoformat()
    return {
        "commit": commit,
        "committed_at": committed_at,
        "author": author,
        "subject": subject,
    }


def is_strict_ancestor(older: str, newer: str) -> bool:
    if older == newer:
        return False
    return git("merge-base", "--is-ancestor", older, newer, check=False).returncode == 0


def select_active(branches: dict[str, str], now: int) -> tuple[dict[str, str], dict[str, str]]:
    if "main" not in branches:
        raise UpdateError("origin/main does not exist")

    omitted: dict[str, str] = {}
    recent: dict[str, str] = {}
    for name, commit in branches.items():
        age = now - commit_time(commit)
        if name == "main" or age <= MAX_AGE_SECONDS:
            recent[name] = commit
        else:
            omitted[name] = "tip commit is older than 48 hours"

    active: dict[str, str] = {}
    for name, commit in recent.items():
        if name == "main":
            active[name] = commit
            continue
        superseding = sorted(
            other
            for other, other_commit in branches.items()
            if other != name and is_strict_ancestor(commit, other_commit)
        )
        if superseding:
            omitted[name] = f"superseded by {', '.join(superseding)}"
        else:
            active[name] = commit
    return active, omitted


def ensure_builder() -> None:
    inspect = run("docker", "image", "inspect", BUILDER_IMAGE, check=False)
    if inspect.returncode == 0:
        return
    print(f"Building missing image {BUILDER_IMAGE}", flush=True)
    result = run(
        "docker",
        "compose",
        "-f",
        str(COMPOSE),
        "--profile",
        "build",
        "build",
        "builder",
        check=False,
        capture=False,
    )
    if result.returncode:
        raise UpdateError("could not build the Godot builder image")


def failure_page(commit: str, log_text: str) -> str:
    return f"""<!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width">
<title>Build failed</title>
<style>body{{font:16px/1.5 system-ui,sans-serif;max-width:1100px;margin:3rem auto;padding:0 1rem;background:#171717;color:#eee}}pre{{white-space:pre-wrap;overflow-wrap:anywhere;background:#080808;padding:1rem;border-radius:.5rem}}a{{color:#8cc8ff}}</style>
</head><body><h1>Build failed</h1><p>Commit <code>{html.escape(commit)}</code></p>
<p><a href="/_branches/">Back to hosted branches</a></p><pre>{html.escape(log_text)}</pre></body></html>
"""


def build_commit(commit: str) -> dict[str, str]:
    destination = CACHE / commit
    metadata_file = destination / "build.json"
    if metadata_file.is_file():
        cached = json.loads(metadata_file.read_text())
        built_at = dt.datetime.fromisoformat(cached["built_at"]).timestamp()
        if cached["status"] == "success" or time.time() - built_at < FAILED_RETRY_SECONDS:
            return cached
        print(f"Retrying failed build {commit[:12]}", flush=True)
        shutil.rmtree(destination)

    work_dir = WORK / f"{commit}-{os.getpid()}"
    export_dir = work_dir / "export"
    export_dir.mkdir(parents=True)
    print(f"Building {commit[:12]}", flush=True)
    command = [
        "docker",
        "compose",
        "-f",
        str(COMPOSE),
        "--profile",
        "build",
        "run",
        "--rm",
        "--no-deps",
        "builder",
        commit,
        f"/state/work/{work_dir.name}/export",
    ]
    builder_environment = os.environ.copy()
    builder_environment["BUILDER_UID"] = str(os.getuid())
    builder_environment["BUILDER_GID"] = str(os.getgid())
    result = subprocess.run(
        command,
        cwd=REPO,
        env=builder_environment,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
    )
    log_text = result.stdout
    status = "success" if result.returncode == 0 else "failed"
    if result.returncode != 0:
        shutil.rmtree(export_dir)
        export_dir.mkdir()
        (export_dir / "index.html").write_text(failure_page(commit, log_text))
    else:
        (export_dir / "build.log").write_text(log_text)

    metadata = {
        "commit": commit,
        "status": status,
        "built_at": dt.datetime.now(dt.timezone.utc).isoformat(),
    }
    (export_dir / "build.json").write_text(json.dumps(metadata, indent=2) + "\n")
    destination.parent.mkdir(parents=True, exist_ok=True)
    os.replace(export_dir, destination)
    shutil.rmtree(work_dir, ignore_errors=True)
    return metadata


def link_tree(source: Path, destination: Path) -> None:
    destination.parent.mkdir(parents=True, exist_ok=True)
    shutil.copytree(source, destination, copy_function=os.link, dirs_exist_ok=True)


def tree_size(path: Path) -> int:
    return sum(entry.stat().st_size for entry in path.rglob("*") if entry.is_file())


def browser_size(path: Path) -> int:
    deploy_only_files = {"build.json", "build.log"}
    return sum(
        entry.stat().st_size
        for entry in path.rglob("*")
        if entry.is_file() and entry.relative_to(path).as_posix() not in deploy_only_files
    )


def format_size(size: int) -> str:
    value = float(size)
    units = ("B", "KiB", "MiB", "GiB", "TiB")
    for unit in units:
        if value < 1024 or unit == units[-1]:
            return f"{int(value)} {unit}" if unit == "B" else f"{value:.1f} {unit}"
        value /= 1024
    raise AssertionError("unreachable")


def branch_index(
    active: dict[str, str],
    metadata: dict[str, dict[str, str]],
    details: dict[str, dict[str, str | int]],
    published_at: dt.datetime,
    next_update_at: dt.datetime,
) -> str:
    items = []
    for branch in sorted(active, key=lambda name: (name != "main", name.casefold())):
        commit = active[branch]
        status = metadata[commit]["status"]
        info = details[commit]
        url = "/" + quote(branch, safe="/") + "/"
        items.append(
            f'<li><details><summary><a href="{html.escape(url)}">{html.escape(branch)}</a> '
            f'<span class="{status}">{status}</span> '
            f'<span class="subject">{html.escape(str(info["subject"]))}</span></summary>'
            f'<dl><dt>Commit</dt><dd><code>{commit}</code></dd>'
            f'<dt>Last updated</dt><dd><time datetime="{info["committed_at"]}">{info["committed_at"]}</time></dd>'
            f'<dt>Author</dt><dd>{html.escape(str(info["author"]))}</dd>'
            f'<dt>Message</dt><dd>{html.escape(str(info["subject"]))}</dd>'
            f'<dt>Server size</dt><dd>{format_size(int(metadata[commit]["size_bytes"]))}</dd>'
            f'<dt>Browser size</dt><dd>{format_size(int(metadata[commit]["browser_size_bytes"]))}</dd>'
            f'<dt>Build finished</dt><dd><time datetime="{metadata[commit]["built_at"]}">{metadata[commit]["built_at"]}</time></dd>'
            f'</dl></details></li>'
        )
    published_iso = published_at.isoformat()
    next_update_iso = next_update_at.isoformat()
    return f"""<!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width">
<title>Hosted branches</title>
<style>body{{font:16px/1.6 system-ui,sans-serif;max-width:900px;margin:3rem auto;padding:0 1rem}}ul{{padding:0;list-style:none}}li{{margin:.75rem 0;padding:.65rem .8rem;border:1px solid #ddd;border-radius:.45rem}}summary{{cursor:pointer}}summary a{{font-weight:650}}summary .subject{{color:#666;margin-left:.5rem}}dl{{display:grid;grid-template-columns:max-content 1fr;gap:.25rem .8rem;margin:.8rem 0 .2rem}}dt{{font-weight:650}}dd{{margin:0;overflow-wrap:anywhere}}code{{color:#666}}.success{{color:#18733c;margin-left:.35rem}}.failed{{color:#b42318;margin-left:.35rem}}.schedule{{padding:.7rem .8rem;background:#f4f4f4;border-radius:.45rem}}@media(max-width:600px){{summary .subject{{display:block;margin-left:0}}dl{{display:block}}dd{{margin-bottom:.4rem}}}}</style>
</head><body><h1>Hosted branches</h1>
<p class="schedule">Next update check: <strong id="countdown">calculating…</strong><br><small>Last published <time datetime="{published_iso}">{published_iso}</time></small></p>
<ul>{''.join(items)}</ul>
<p><small>Server size is the branch export's logical size. Browser size is its cold-cache, browser-facing payload and excludes build metadata and logs; HTTP caching and compression can change the transferred amount. Branches on the same commit share one cached copy on disk.</small></p>
<script>
const nextUpdate = new Date({json.dumps(next_update_iso)}).getTime();
const countdown = document.getElementById("countdown");
function updateCountdown() {{
  const seconds = Math.max(0, Math.ceil((nextUpdate - Date.now()) / 1000));
  if (seconds === 0) {{ countdown.textContent = "due now"; return; }}
  const minutes = Math.floor(seconds / 60);
  const remainder = seconds % 60;
  countdown.textContent = minutes ? `${{minutes}}m ${{String(remainder).padStart(2, "0")}}s` : `${{remainder}}s`;
}}
document.querySelectorAll("time").forEach((element) => {{
  element.textContent = new Date(element.dateTime).toLocaleString();
}});
updateCountdown();
setInterval(updateCountdown, 1000);
</script></body></html>
"""


def publish(
    active: dict[str, str],
    metadata: dict[str, dict[str, str]],
    details: dict[str, dict[str, str | int]],
    update_started_at: float,
) -> None:
    next_www = STATE / f"www.next-{os.getpid()}"
    old_www = STATE / f"www.old-{os.getpid()}"
    shutil.rmtree(next_www, ignore_errors=True)
    next_www.mkdir(parents=True)

    for branch, commit in active.items():
        link_tree(CACHE / commit, next_www / branch)

    listing = next_www / "_branches"
    listing.mkdir()
    published_at = dt.datetime.now(dt.timezone.utc)
    next_timestamp = max(time.time(), update_started_at + 60)
    next_update_at = dt.datetime.fromtimestamp(next_timestamp, dt.timezone.utc)
    (listing / "index.html").write_text(
        branch_index(active, metadata, details, published_at, next_update_at)
    )

    if WWW.exists():
        os.replace(WWW, old_www)
    os.replace(next_www, WWW)
    shutil.rmtree(old_www, ignore_errors=True)


def cleanup(active_commits: set[str]) -> None:
    shutil.rmtree(WORK, ignore_errors=True)
    WORK.mkdir(parents=True)
    if CACHE.exists():
        for entry in CACHE.iterdir():
            if entry.name not in active_commits:
                shutil.rmtree(entry)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--skip-fetch", action="store_true", help="use current origin refs")
    args = parser.parse_args()

    update_started_at = time.time()
    STATE.mkdir(parents=True, exist_ok=True)
    lock_file = (STATE / "update.lock").open("w")
    try:
        fcntl.flock(lock_file, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except BlockingIOError:
        print("Another update is already running; exiting")
        return 0

    try:
        if not args.skip_fetch:
            fetch()
        branches = remote_branches()
        active, omitted = select_active(branches, int(time.time()))
        print("Active branches: " + ", ".join(sorted(active)), flush=True)
        for branch, reason in sorted(omitted.items()):
            print(f"Omitting {branch}: {reason}", flush=True)

        ensure_builder()
        metadata: dict[str, dict[str, str]] = {}
        details: dict[str, dict[str, str | int]] = {}
        for commit in dict.fromkeys(active.values()):
            metadata[commit] = build_commit(commit)
            metadata[commit]["size_bytes"] = str(tree_size(CACHE / commit))
            metadata[commit]["browser_size_bytes"] = str(browser_size(CACHE / commit))
            details[commit] = commit_details(commit)
        publish(active, metadata, details, update_started_at)
        cleanup(set(active.values()))
        print("Published branch site", flush=True)
        return 0
    except (OSError, subprocess.SubprocessError, UpdateError, ValueError) as error:
        print(f"Update failed: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
