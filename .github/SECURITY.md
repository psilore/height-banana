# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |

## Reporting a Vulnerability

**Please do not report security vulnerabilities through public GitHub issues.**

Instead, please report them via email to: security@height-banana.app

You should receive a response within 48 hours. If for some reason you do not, please follow up to ensure we received your original message.

Please include the following information:
- Type of issue (e.g. buffer overflow, SQL injection, cross-site scripting, etc.)
- Full paths of source file(s) related to the issue
- Location of the affected source code (tag/branch/commit or direct URL)
- Any special configuration required to reproduce the issue
- Step-by-step instructions to reproduce the issue
- Proof-of-concept or exploit code (if possible)
- Impact of the issue

## Security Best Practices

This project follows these security practices:

✅ **No hardcoded secrets** - All credentials in GitHub Secrets or local .env files
✅ **Firestore security rules** - User data is uid-scoped
✅ **CodeQL scanning** - Automated vulnerability detection
✅ **Dependabot** - Automatic dependency updates
✅ **Secret scanning** - GitHub secret scanning enabled
✅ **Input validation** - All user inputs validated
✅ **Secure authentication** - OAuth 2.0 via Firebase Auth

## Security Checklist

- [x] Firebase security rules implemented
- [x] Google Sign-In OAuth configured
- [x] No API keys in source code
- [x] CodeQL security scanning enabled
- [x] Dependabot alerts configured
- [x] HTTPS for all network requests
- [ ] Penetration testing (planned)
- [ ] Security audit (planned)

## Disclosure Policy

When we receive a security bug report, we will:

1. Confirm the problem and determine affected versions
2. Audit code to find similar problems
3. Prepare fixes for all supported versions
4. Release new versions and notify users

## Attribution

We appreciate security researchers who responsibly disclose vulnerabilities. We will acknowledge your contribution in our release notes (unless you prefer to remain anonymous).
