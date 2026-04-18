#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
data_file="$repo_root/home/.chezmoidata.yaml"
script_template="$repo_root/home/run_onchange_install-packages.sh.tmpl"

if ! grep -q '^bootstrap:' "$data_file"; then
  echo "expected bootstrap manifest in $data_file" >&2
  exit 1
fi

if ! grep -q '^platforms:' "$data_file"; then
  echo "expected platform mapping manifest in $data_file" >&2
  exit 1
fi

rendered_script="$(mktemp)"
trap 'rm -f "$rendered_script"' EXIT

chezmoi execute-template --source "$repo_root" --file "$script_template" >"$rendered_script"

for pattern in \
  'CURRENT_DISTRO_FAMILY=' \
  'CURRENT_PACKAGE_MANAGER=' \
  'install_linux_packages()' \
  'install_darwin_packages()' \
  'DEBIAN_SYSTEM_PACKAGES=(' \
  'ARCH_SYSTEM_PACKAGES=(' \
  'RHEL_SYSTEM_PACKAGES=(' \
  'unsupported Linux distribution family'; do
  if ! grep -q "$pattern" "$rendered_script"; then
    echo "expected rendered bootstrap script to contain: $pattern" >&2
    exit 1
  fi
done

echo "bootstrap platform regression test passed"
