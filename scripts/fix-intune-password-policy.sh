#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    exec sudo bash "$0" "$@"
fi

PAM_FILE="/etc/pam.d/common-password"

echo "=== Backing up $PAM_FILE ==="
cp "$PAM_FILE" "${PAM_FILE}.bak"

echo "=== Updating pam_pwquality.so line with inline options ==="
# Replace the pam_pwquality.so line to include required options inline,
# since pam_intune.so parses the PAM line directly rather than reading pwquality.conf
sed -i 's|^\(password.*pam_pwquality\.so\).*|\1 retry=3 minlen=8 dcredit=-1 ucredit=-1 lcredit=-1 ocredit=-1 enforce_for_root|' "$PAM_FILE"

echo "=== Result ==="
grep "pam_pwquality" "$PAM_FILE"

echo ""
echo "=== Restarting intune-daemon ==="
systemctl restart intune-daemon || true

echo ""
echo "Done. Click 'Refresh' in the Intune Portal to re-check compliance."
