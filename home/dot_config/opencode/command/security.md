---
description: Security audit — find vulnerabilities, silent failures, and unsafe patterns
agent: reviewer
subtask: true
---

Perform a security-focused audit on $ARGUMENTS (files, directory, or recent diff). If no arguments, audit the current diff against main.

Scan for:

**Input & injection**
- SQL injection, command injection, path traversal
- XSS (unsanitized output to HTML/JS contexts)
- Missing input validation at system boundaries

**Authentication & authorization**
- Missing auth checks on routes/handlers
- Insecure session management
- Privilege escalation paths

**Data exposure**
- Secrets or credentials in code or logs
- Sensitive data logged or returned in error messages
- Unencrypted PII at rest or in transit

**Error handling (silent failures)**
- Exceptions swallowed silently
- Fallback values that mask real errors
- Missing error propagation to callers

**Dependencies**
- `npm audit` / `cargo audit` / `go list -m -json all | nancy` results
- Known CVEs in pinned versions

**Configuration**
- Overly permissive CORS, CSP, or file permissions
- Debug endpoints or verbose errors in production paths

Output each finding as:
```
[CRITICAL|HIGH|MEDIUM|LOW] path/file:line
Vulnerability: [type]
Risk: [what an attacker could do]
Fix: [specific remediation]
```

End with a count per severity and overall risk rating.
Do not apply fixes. Report only.
