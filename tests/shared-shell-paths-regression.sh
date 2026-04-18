#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

bin_dir="$tmpdir/bin"
brew_prefix="$tmpdir/homebrew"
mkdir -p "$bin_dir" "$brew_prefix/bin" "$brew_prefix/opt/fzf/bin" "$brew_prefix/opt/nvm" "$tmpdir/nvm"

cat >"$bin_dir/brew" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

prefix="${TEST_BREW_PREFIX:?}"

if [[ "${1:-}" == "shellenv" ]]; then
  cat <<SH
export HOMEBREW_PREFIX="$prefix"
export PATH="$prefix/bin:\$PATH"
SH
  exit 0
fi

if [[ "${1:-}" == "--prefix" ]]; then
  case "${2:-}" in
    fzf)
      printf '%s\n' "$prefix/opt/fzf"
      ;;
    nvm)
      printf '%s\n' "$prefix/opt/nvm"
      ;;
    *)
      printf '%s\n' "$prefix"
      ;;
  esac
  exit 0
fi

printf 'unexpected brew invocation: %s\n' "$*" >&2
exit 1
EOF
chmod 700 "$bin_dir/brew"

cat >"$brew_prefix/opt/fzf/bin/fzf" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

case "${1:-}" in
  --bash)
    printf '%s\n' 'export FZF_BASH_LOADED=1'
    ;;
  --zsh)
    printf '%s\n' 'export FZF_ZSH_LOADED=1'
    ;;
  *)
    printf 'unexpected fzf invocation: %s\n' "$*" >&2
    exit 1
    ;;
esac
EOF
chmod 700 "$brew_prefix/opt/fzf/bin/fzf"

cat >"$brew_prefix/opt/nvm/nvm.sh" <<'EOF'
#!/usr/bin/env bash
nvm() {
  printf 'fake-nvm %s\n' "$*"
}
true
EOF
chmod 700 "$brew_prefix/opt/nvm/nvm.sh"

if ! TEST_BREW_PREFIX="$brew_prefix" PATH="$bin_dir:/usr/bin:/bin" bash -c "source '$repo_root/home/dot_zprofile'; [[ \$HOMEBREW_PREFIX == '$brew_prefix' ]]"; then
  echo "expected dot_zprofile to use brew shellenv from PATH" >&2
  exit 1
fi

if ! TEST_BREW_PREFIX="$brew_prefix" PATH="$bin_dir:/usr/bin:/bin" bash -c "source '$repo_root/home/dot_fzf.bash'; [[ :\$PATH: == *':$brew_prefix/opt/fzf/bin:'* ]] && [[ \${FZF_BASH_LOADED:-0} == 1 ]]"; then
  echo "expected dot_fzf.bash to detect fzf via brew prefix" >&2
  exit 1
fi

if ! TEST_BREW_PREFIX="$brew_prefix" PATH="$bin_dir:/usr/bin:/bin" zsh -c "source '$repo_root/home/dot_fzf.zsh'; [[ :\$PATH: == *':$brew_prefix/opt/fzf/bin:'* ]] && [[ \${FZF_ZSH_LOADED:-0} == 1 ]]"; then
  echo "expected dot_fzf.zsh to detect fzf via brew prefix" >&2
  exit 1
fi

if ! TEST_BREW_PREFIX="$brew_prefix" PATH="$bin_dir:/usr/bin:/bin" zsh -c "source '$repo_root/home/dot_config/dotfiles/nvm.zsh'; output=\$(nvm current); [[ \$output == fake-nvm\ current ]]"; then
  echo "expected nvm.zsh to resolve nvm via brew prefix" >&2
  exit 1
fi

rendered_git_config="$(mktemp)"
chezmoi execute-template --source "$repo_root" --file "$repo_root/home/dot_config/git/config.tmpl" >"$rendered_git_config"
trap 'rm -rf "$tmpdir" "$rendered_git_config"' EXIT

if ! grep -q 'helper = !gh auth git-credential' "$rendered_git_config"; then
  echo "expected git config to use gh from PATH" >&2
  exit 1
fi

if grep -q '/opt/homebrew/bin/gh auth git-credential' "$rendered_git_config"; then
  echo "expected git config to avoid hardcoded Homebrew gh path" >&2
  exit 1
fi

echo "shared shell path regression test passed"
