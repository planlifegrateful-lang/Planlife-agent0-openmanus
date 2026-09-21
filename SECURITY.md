# Pipeline security and operations

This repository supports local media generation and optional integrations.

## Safety rules

- Keep credentials in environment variables or platform secret stores.
- Never commit `.env`, tokens, webhook secrets, private voice material, or customer media.
- Validate webhook input before invoking media tools.
- Treat generated files as untrusted input when passed to external tools.
- Keep output directories out of version control unless a small fixture is explicitly required.

## Operational readiness

Before calling a deployment production-ready, verify the documented health checks, ports, system dependencies, failure behavior, and cleanup policy for generated media.
