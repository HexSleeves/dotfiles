#!/usr/bin/env bash
set -euo pipefail

# Gathers branch and diff metadata for the /local-review command.
# Outputs structured JSON to stdout. All errors are also JSON.
# Exit 0: ok or warning. Exit 1: error (cannot proceed).

# Detect the repo's default branch. Prefer the remote HEAD ref
# (e.g. origin/main, origin/master); fall back to whichever of
# main/master exists locally; finally default to main.
detect_base_branch() {
  local ref
  ref=$(git symbolic-ref -q --short refs/remotes/origin/HEAD 2>/dev/null) && {
    printf '%s' "${ref#origin/}"; return
  }
  for candidate in main master; do
    if git show-ref --verify --quiet "refs/heads/$candidate"; then
      printf '%s' "$candidate"; return
    fi
  done
  printf 'main'
}

BASE_BRANCH=$(detect_base_branch)

# Resolve a ref that actually exists for merge-base. The bare branch name
# (e.g. "main") may have no local ref in a single-branch clone, a worktree, or
# a CI checkout where only origin/main exists — merge-base against the bare
# name would then fail with a misleading "no common ancestor" error. Prefer a
# local branch ref, fall back to the remote-tracking ref, then the bare name.
resolve_base_ref() {
  if git show-ref --verify --quiet "refs/heads/$BASE_BRANCH"; then
    printf '%s' "$BASE_BRANCH"
  elif git show-ref --verify --quiet "refs/remotes/origin/$BASE_BRANCH"; then
    printf 'origin/%s' "$BASE_BRANCH"
  else
    printf '%s' "$BASE_BRANCH"
  fi
}

BASE_REF=$(resolve_base_ref)

# --- Helpers ---

json_escape() {
  # Reads stdin fully and outputs a JSON-encoded string (with quotes).
  # Uses printf '%s' to avoid trailing newline from echo.
  python3 -c 'import json, sys; sys.stdout.write(json.dumps(sys.stdin.read()))'
}

emit_error() {
  local msg="$1"
  printf '{"status":"error","message":%s}\n' "$(printf '%s' "$msg" | json_escape)"
  exit 1
}

# --- Pre-flight checks ---

# Detached HEAD
if ! git symbolic-ref -q HEAD >/dev/null 2>&1; then
  emit_error "Detached HEAD state. Check out a branch before running a review."
fi

BRANCH=$(git rev-parse --abbrev-ref HEAD)
HEAD_SHA=$(git rev-parse --short HEAD)

# On main
if [ "$BRANCH" = "$BASE_BRANCH" ]; then
  if [ -n "$(git status --porcelain)" ]; then
    # Warning: on main with uncommitted changes
    STATUS="warning"
    MESSAGE="You are on $BASE_BRANCH with uncommitted changes. Features should be developed on a separate branch."
  else
    emit_error "On $BASE_BRANCH with no changes. Create a feature branch first."
  fi
else
  STATUS="ok"
  MESSAGE="Ready for review."
fi

# Merge base
MERGE_BASE=$(git merge-base HEAD "$BASE_REF" 2>/dev/null) || \
  emit_error "No common ancestor with $BASE_BRANCH. Is this branch based on $BASE_BRANCH?"

MERGE_BASE_SHORT=$(git rev-parse --short "$MERGE_BASE")

# New files that were never staged are invisible to `git diff`, so capture them
# separately and factor them into both the "has changes" gate and the file
# count. Without this, a branch whose only work is untracked files is wrongly
# rejected as having no changes, and the stat reports 0 files while the
# inventory below still lists those paths.
UNTRACKED=$(git ls-files --others --exclude-standard 2>/dev/null)

# Check for changes (committed, uncommitted, or untracked) against merge base
if git diff --no-ext-diff --quiet "$MERGE_BASE" 2>/dev/null && [ -z "$UNTRACKED" ] && [ "$STATUS" != "warning" ]; then
  emit_error "No changes found between $BASE_BRANCH and current state."
fi

# --- Gather data ---

# Uncommitted changes detection
INCLUDES_UNCOMMITTED=false
if [ -n "$(git status --porcelain)" ]; then
  INCLUDES_UNCOMMITTED=true
fi

# Diff stat — use merge base to working tree to include uncommitted changes
STAT_OUTPUT=$(git diff --no-ext-diff --shortstat "$MERGE_BASE" 2>/dev/null || echo "")
FILES_CHANGED=0
INSERTIONS=0
DELETIONS=0

if [ -n "$STAT_OUTPUT" ]; then
  FILES_CHANGED=$(echo "$STAT_OUTPUT" | grep -oE '[0-9]+ file' | grep -oE '[0-9]+' || echo 0)
  INSERTIONS=$(echo "$STAT_OUTPUT" | grep -oE '[0-9]+ insertion' | grep -oE '[0-9]+' || echo 0)
  DELETIONS=$(echo "$STAT_OUTPUT" | grep -oE '[0-9]+ deletion' | grep -oE '[0-9]+' || echo 0)
fi

# shortstat only counts tracked changes; add untracked files so files_changed
# agrees with the inventory below (which lists them).
if [ -n "$UNTRACKED" ]; then
  UNTRACKED_COUNT=$(printf '%s\n' "$UNTRACKED" | grep -c .)
  FILES_CHANGED=$((FILES_CHANGED + UNTRACKED_COUNT))
fi

# Commit log (on branch, not on base)
COMMITS_JSON="["
FIRST_COMMIT=true
while IFS= read -r line; do
  [ -z "$line" ] && continue
  sha="${line%% *}"
  msg="${line#* }"
  escaped_msg=$(printf '%s' "$msg" | json_escape)
  if [ "$FIRST_COMMIT" = true ]; then
    FIRST_COMMIT=false
  else
    COMMITS_JSON+=","
  fi
  COMMITS_JSON+="{\"sha\":\"$sha\",\"message\":$escaped_msg}"
done < <(git log --format='%h %s' "$MERGE_BASE..HEAD" 2>/dev/null)
COMMITS_JSON+="]"

# File inventory (committed + uncommitted vs merge base)
FILES_JSON="["
FIRST_FILE=true

append_file() {
  local file_status="$1" file_path="$2"
  escaped_path=$(printf '%s' "$file_path" | json_escape)
  if [ "$FIRST_FILE" = true ]; then
    FIRST_FILE=false
  else
    FILES_JSON+=","
  fi
  FILES_JSON+="{\"status\":\"$file_status\",\"path\":$escaped_path}"
}

# Tracked changes (modified, deleted, added via index)
while IFS=$'\t' read -r status path; do
  [ -z "$status" ] && continue
  append_file "$status" "$path"
done < <(git diff --no-ext-diff --name-status "$MERGE_BASE" 2>/dev/null)

# Untracked new files (not gitignored) — reuse the list captured above
while IFS= read -r path; do
  [ -z "$path" ] && continue
  append_file "?" "$path"
done < <(printf '%s\n' "$UNTRACKED")

FILES_JSON+="]"

# Full diff (merge base to working tree)
DIFF_ESCAPED=$(git diff --no-ext-diff "$MERGE_BASE" 2>/dev/null | json_escape)

# --- Build output ---

escaped_message=$(printf '%s' "$MESSAGE" | json_escape)

cat <<ENDJSON
{
  "status": "$STATUS",
  "message": $escaped_message,
  "branch": "$BRANCH",
  "base": "$BASE_BRANCH",
  "merge_base_sha": "$MERGE_BASE_SHORT",
  "head_sha": "$HEAD_SHA",
  "includes_uncommitted": $INCLUDES_UNCOMMITTED,
  "stats": {
    "files_changed": $FILES_CHANGED,
    "insertions": $INSERTIONS,
    "deletions": $DELETIONS
  },
  "commits": $COMMITS_JSON,
  "files": $FILES_JSON,
  "diff": $DIFF_ESCAPED
}
ENDJSON
