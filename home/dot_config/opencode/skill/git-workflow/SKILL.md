---
name: git-workflow
description: Git commit, branch, and PR workflow — conventional commits, safe operations, and PR creation with gh CLI
---

# Git Workflow

## Commit Convention

Format: `type(scope): description`

| Type | When |
|---|---|
| `feat` | New feature or behavior |
| `fix` | Bug fix |
| `refactor` | Code change with no behavior change |
| `perf` | Performance improvement |
| `test` | Adding or fixing tests |
| `docs` | Documentation only |
| `chore` | Build, deps, tooling |
| `ci` | CI/CD changes |

Rules:
- Description is lowercase, imperative mood ("add X" not "adds X" or "added X")
- Scope is optional but helpful: `feat(auth): add refresh token rotation`
- Body explains WHY, not what (the diff already shows what)
- Breaking changes get `!`: `feat!: rename UserID to user_id`

## Commit Flow

```bash
# Stage specific files (never `git add .` blindly)
git add src/auth/session.ts src/auth/types.ts

# Verify what you're committing
git diff --cached

# Commit
git commit -m "feat(auth): add refresh token rotation"

# Or with body
git commit -m "fix(auth): prevent token reuse after refresh

Tokens were not being invalidated after rotation, allowing
a stolen token to remain valid. Invalidate old token on issue."
```

## Safe Operations

**Always safe:**
```bash
git status
git log --oneline
git diff
git diff main...HEAD
git stash
git stash pop
```

**Ask first (destructive or shared):**
```bash
git push --force-with-lease   # safer than --force, still ask
git reset --hard              # discards local changes
git checkout .                # discards all unstaged changes
git clean -fd                 # deletes untracked files
```

**Never do:**
```bash
git push --force origin main   # destroys shared history
git reset --hard origin/main   # without checking for local work
```

## Branch Workflow

```bash
# Create feature branch from main
git checkout main && git pull
git checkout -b feat/refresh-token-rotation

# Keep branch current
git fetch origin
git rebase origin/main   # preferred over merge for clean history

# Done — push and open PR
git push -u origin HEAD
gh pr create --title "feat(auth): add refresh token rotation" --body "..."
```

## PR Creation with gh

```bash
gh pr create \
  --title "feat(auth): add refresh token rotation" \
  --body "$(cat <<'EOF'
## Summary
- Implements RFC 6819 token rotation: old token invalidated on refresh
- Prevents replay attacks with stolen refresh tokens

## Test plan
- [ ] Refresh flow issues new tokens
- [ ] Old token rejected after refresh
- [ ] Concurrent refresh handled correctly
EOF
)"
```

## Useful Shortcuts

```bash
# See what's going into a PR
git log main...HEAD --oneline

# What files changed
git diff --name-only main...HEAD

# Undo last commit (keep changes staged)
git reset --soft HEAD~1

# Amend last commit message (before pushing)
git commit --amend --no-edit

# Stash including untracked files
git stash -u

# Find which commit introduced a bug
git bisect start
git bisect bad HEAD
git bisect good <known-good-sha>
```
