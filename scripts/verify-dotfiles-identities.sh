#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

render() {
  chezmoi execute-template < "$1"
}

git_config="$(render home/dot_config/git/config.tmpl)"
ssh_config="$(render home/private_dot_ssh/private_config.tmpl)"

grep_fixed() {
  grep -F "$1" >/dev/null
}

printf '%s\n' "$git_config" | grep_fixed '[includeIf "gitdir:~/Developer/personal/"]' || fail "missing personal gitdir include"
printf '%s\n' "$git_config" | grep_fixed '[includeIf "gitdir/i:~/Work/bayer/"]' || fail "missing bayer work gitdir include"
printf '%s\n' "$git_config" | grep_fixed '[includeIf "gitdir/i:~/Work/liatrio/"]' || fail "missing liatrio work gitdir include"

printf '%s\n' "$git_config" | grep_fixed 'path = ~/.config/git/identity.personal' || fail "missing personal identity include path"
printf '%s\n' "$git_config" | grep_fixed 'path = ~/.config/git/identity.bayer' || fail "missing bayer identity include path"
printf '%s\n' "$git_config" | grep_fixed 'path = ~/.config/git/identity.liatrio' || fail "missing liatrio identity include path"

if printf '%s\n' "$git_config" | grep -Fq '[coderabbit]'; then
  fail "managed git config should not contain machine-specific coderabbit state"
fi

if printf '%s\n' "$git_config" | grep -Fq 'sshCommand = ssh -i'; then
  fail "managed git config should not force one global ssh identity"
fi

for identity in personal bayer liatrio; do
  path="home/dot_config/git/identity.$identity.tmpl"
  [ -f "$path" ] || fail "missing $path"
done

render home/dot_config/git/identity.personal.tmpl | grep_fixed 'email = "lecoqjacob@gmail.com"' || fail "personal identity email mismatch"
render home/dot_config/git/identity.bayer.tmpl | grep_fixed 'email = "jacob.lecoq.ext@bayer.com"' || fail "bayer identity email mismatch"
render home/dot_config/git/identity.liatrio.tmpl | grep_fixed 'email = "jacob.lecoq@liatrio.com"' || fail "liatrio identity email mismatch"

if printf '%s\n' "$ssh_config" | grep -Eq 'Host github-(personal|bayer|liatrio)'; then
  fail "managed SSH config should use one GitHub account/key via github.com"
fi
printf '%s\n' "$ssh_config" | awk '
  /^Host github.com$/ { in_github=1; next }
  /^Host / { in_github=0 }
  in_github && /IdentityFile ~\/\.ssh\/id_ed25519/ { found=1 }
  END { exit found ? 0 : 1 }
' || fail "github.com should use ~/.ssh/id_ed25519"
printf '%s\n' "$ssh_config" | grep_fixed 'IgnoreUnknown UseKeychain' || fail "missing portable UseKeychain guard"

[ -f home/dot_config/ripgrep/config ] || fail "missing managed ripgrep config"

if [ -e home/bootstrap/gpg/gpg-keyring.tgz.gpg ]; then
  fail "chezmoi should not store the canonical GPG archive; use Ansible vault_gpg_keyring_b64"
fi

ansible_ripgrep_config="/Users/lecoqjacob/Developer/infra/ansible-dotfiles/roles/tools/files/config/ripgrep/config"
[ -f "$ansible_ripgrep_config" ] || fail "missing Ansible ripgrep config"
grep -F -- '- ripgrep' /Users/lecoqjacob/Developer/infra/ansible-dotfiles/roles/tools/tasks/main.yml >/dev/null || fail "Ansible tools role does not deploy ripgrep config"

ansible_vars="/Users/lecoqjacob/Developer/infra/ansible-dotfiles/inventory/group_vars/all/vars.yml"
grep -F 'signing_key: "758709BBEB67145DE844FC85C61F052D671268B5"' "$ansible_vars" >/dev/null || fail "Ansible signing key is not aligned with chezmoi"
grep -F 'personal_email: "lecoqjacob@gmail.com"' "$ansible_vars" >/dev/null || fail "Ansible personal email missing"
grep -F 'bayer_email: "jacob.lecoq.ext@bayer.com"' "$ansible_vars" >/dev/null || fail "Ansible Bayer email missing"
grep -F 'liatrio_email: "jacob.lecoq@liatrio.com"' "$ansible_vars" >/dev/null || fail "Ansible Liatrio email missing"

ansible_git_role="/Users/lecoqjacob/Developer/infra/ansible-dotfiles/roles/git"
for identity in personal bayer liatrio; do
  [ -f "$ansible_git_role/templates/identity.$identity.j2" ] || fail "missing Ansible identity.$identity.j2"
done
grep -F 'identity.{{ item }}.j2' "$ansible_git_role/tasks/main.yml" >/dev/null || fail "Ansible git role does not template identity configs"

ansible_ssh_template="/Users/lecoqjacob/Developer/infra/ansible-dotfiles/roles/ssh/templates/config.j2"
if grep -Eq 'Host github-(personal|bayer|liatrio)' "$ansible_ssh_template"; then
  fail "Ansible SSH template should use one GitHub account/key via github.com"
fi
awk '
  /^Host github.com$/ { in_github=1; next }
  /^Host / { in_github=0 }
  in_github && /IdentityFile ~\/\.ssh\/id_ed25519/ { found=1 }
  END { exit found ? 0 : 1 }
' "$ansible_ssh_template" || fail "Ansible github.com should use ~/.ssh/id_ed25519"
grep -F 'IgnoreUnknown UseKeychain' "$ansible_ssh_template" >/dev/null || fail "Ansible SSH template missing UseKeychain guard"

ansible_hosts="/Users/lecoqjacob/Developer/infra/ansible-dotfiles/inventory/hosts"
if awk '/^\[personal\]/{flag=1; next} /^\[/{flag=0} flag && $1 == "localhost"{found=1} END{exit found ? 0 : 1}' "$ansible_hosts"; then
  fail "Ansible inventory should not force localhost into personal"
fi

printf 'identity verification passed\n'
