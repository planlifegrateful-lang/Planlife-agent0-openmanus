# OpenManus – Planlife Zero-API Pipeline

Quick tools to run the video pipeline **without Docker**.

## Files

| File | What it does |
|------|--------------|
| `TASK_PROMPT_native_setup.md` | Full Manus/OpenManus task prompt |
| `TASK_PROMPT_short.md` | Short version |
| `TASK_PROMPT_termux.md` | Termux (Android) version |
| `start-native.sh` | One-command starter for Linux/macOS |
| `start-termux.sh` | Full install + start script for Termux |

## Quick Start

### PC / Server (native)
```bash
cd Planlife-agent0-openmanus
chmod +x OpenManus/start-native.sh
bash OpenManus/start-native.sh
```

### Android (Termux)
```bash
# First time: copy start-termux.sh content or clone repo
bash OpenManus/start-termux.sh
```

### Feed to Manus
Copy any `TASK_PROMPT_*.md` content and paste into Manus AI or local OpenManus.

## Ports
- Content Agent: 8100
- Webhook Listener: 8000
- Video Builder: 8001
