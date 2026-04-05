# Security Policy

## Supported Versions

We currently support the following versions with security updates:

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

If you discover a security vulnerability, please send an email to security@example.com. All security vulnerabilities should be reported and will be promptly addressed.

Please include the following information:
- Type of vulnerability
- Full paths of source file(s) related to the vulnerability
- Location of the affected source code (branch/tag or direct URL)
- Step-by-step instructions to reproduce the issue
- Proof-of-concept or exploit code (if possible)
- Impact of the issue

## Security Best Practices

- Never commit secrets, API keys, or credentials to version control
- Use environment variables for sensitive configuration
- Follow the principle of least privilege
- Validate and sanitize all user inputs
- Use secure communication protocols (HTTPS, SSH)
- Implement proper authentication and authorization

## Dependencies

We regularly scan for vulnerabilities in dependencies using:
- npm audit
- GitHub Dependabot
- Snyk or similar tools