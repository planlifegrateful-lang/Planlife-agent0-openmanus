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


## Docker Compose exposure hardening

The Compose stack publishes the video builder, webhook listener, OpenManus, and n8n ports on 127.0.0.1 by default. Keep these loopback bindings unless you intentionally place a reviewed authenticated reverse proxy in front of the service. Do not change them to 0.0.0.0 merely to make a remote device connect; use a VPN or authenticated HTTPS proxy instead.

The stack must not rely on the old `N8N_BASIC_AUTH_*` variables or a default password such as `changeme`. Current n8n versions use their own user-management/owner setup; complete that setup with a unique strong password. Loopback binding is a network exposure reduction, not a substitute for n8n account security. Confirm the exact behavior of the deployed n8n version before claiming authentication is configured.

After applying this change, validate the Compose file with `docker compose config`, start the stack, and confirm each published port listens only on 127.0.0.1. This repository edit alone does not prove the host firewall, reverse proxy, or live service exposure.
