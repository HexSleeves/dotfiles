#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    exec sudo bash "$0" "$@"
fi

echo "=== Adding Microsoft noble repo ==="
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/ubuntu/24.04/prod noble main" \
    > /etc/apt/sources.list.d/microsoft-prod-noble.list

echo "=== Setting package pin priorities ==="
cat > /etc/apt/preferences.d/microsoft-noble <<'EOF'
Package: *
Pin: release n=noble
Pin-Priority: 100

Package: intune-portal microsoft-identity-broker
Pin: origin packages.microsoft.com
Pin-Priority: 500
EOF

echo "=== Updating package lists ==="
apt-get update

echo "=== Installing intune-portal ==="
apt-get -y install intune-portal

echo ""
echo "Done. Launch 'Intune Portal' from your application menu to enroll."
