#!/bin/bash
#
# Local-only repo state snapshotter for /opt/lab-infra.
#
# Captures the current working-tree state as a commit on the local-only
# branch `auto-snapshots`. NEVER pushes to any remote. Does NOT touch
# HEAD, the regular index, or the working tree, so `git pull origin main`
# and manual work on `main` keep running in parallel.
#
# Use case: if someone edits a file on the server and forgets to commit
# it via the normal flow, the next tick captures that state so it can be
# recovered (`git log auto-snapshots`, `git show <sha>`, cherry-pick).
#
# Intentionally does NOT cover full disaster recovery — that's what the
# VM snapshot and scripts/backup-postgres.sh are for.
#
# Design notes:
#   - Uses a temporary index (GIT_INDEX_FILE) + git plumbing so the
#     working tree and real .git/index are never modified.
#   - Skips commit if the captured tree is identical to the last
#     snapshot's tree (no growth on a stable system).
#   - Retention: none. Branch grows on real changes only; run
#     `git gc` periodically if the pack gets large.

set -u
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

REPO_DIR=/opt/lab-infra
BRANCH=auto-snapshots

cd "$REPO_DIR" || { echo "[auto-snapshot] FATAL: cannot cd to $REPO_DIR" >&2; exit 1; }

# Sanity: are we in a git repo?
if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "[auto-snapshot] FATAL: $REPO_DIR is not a git repository" >&2
  exit 1
fi

# Build the snapshot tree in a temporary index so the real .git/index
# and the working tree are untouched.
TMP_INDEX=$(mktemp)
trap 'rm -f "$TMP_INDEX"' EXIT

# Seed temp index from HEAD's tree, then add everything currently on disk.
# `git add -A` respects .gitignore, so ignored files (.env, logs, backups)
# never enter the snapshot.
GIT_INDEX_FILE="$TMP_INDEX" git read-tree HEAD
GIT_INDEX_FILE="$TMP_INDEX" git add -A

TREE=$(GIT_INDEX_FILE="$TMP_INDEX" git write-tree)

# Pick parent commit: auto-snapshots tip if it exists, otherwise HEAD
# (first run bootstraps the branch from the current main tip).
if git show-ref --verify --quiet "refs/heads/$BRANCH"; then
  PARENT=$(git rev-parse "refs/heads/$BRANCH")
else
  PARENT=$(git rev-parse HEAD)
fi

PARENT_TREE=$(git rev-parse "$PARENT^{tree}")

# Bail out if nothing changed since the last snapshot.
if [ "$TREE" = "$PARENT_TREE" ]; then
  echo "[auto-snapshot] No changes since last snapshot; nothing to do"
  exit 0
fi

# Summary of what changed for a useful commit subject.
CHANGED_COUNT=$(GIT_INDEX_FILE="$TMP_INDEX" git diff --cached --name-only "$PARENT" \
  | wc -l | tr -d ' ')
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
MSG="auto-snapshot: $TIMESTAMP ($CHANGED_COUNT file(s) changed)"

# Create commit object (no ref update yet), then advance only the
# auto-snapshots ref. HEAD is not touched.
COMMIT=$(printf '%s\n' "$MSG" | git commit-tree "$TREE" -p "$PARENT")
git update-ref "refs/heads/$BRANCH" "$COMMIT" "$PARENT" 2>/dev/null || \
  git update-ref "refs/heads/$BRANCH" "$COMMIT"

echo "[auto-snapshot] recorded $COMMIT on $BRANCH ($CHANGED_COUNT file(s))"
