---
title: OpenClaw AI Gateway
emoji: 🐾
colorFrom: indigo
colorTo: purple
sdk: docker
pinned: true
app_port: 7860
---

# 🐾 OpenClaw AI Gateway — Hugging Face Spaces

A self-hosted OpenClaw instance powered by NVIDIA NIM models, running on Hugging Face Spaces with Docker.

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│  Hugging Face Space (Docker)                            │
│  ┌───────────────────────────────────────────────────┐  │
│  │  OpenClaw Gateway (:7860)                         │  │
│  │  ├── Control UI (Web Chat)                        │  │
│  │  ├── Agent Runtime                                │  │
│  │  ├── Tool Execution (exec, fs, web_search)        │  │
│  │  └── Model Router                                 │  │
│  └───────────────┬───────────────────────────────────┘  │
│                  │                                       │
│  ┌───────────────▼───────────────────────────────────┐  │
│  │  NVIDIA NIM API                                   │  │
│  │  ├── General: kimi-k2.6, deepseek-v4-pro, glm-5.1│  │
│  │  ├── Coding:  qwen3-coder-480b, nemotron-3-super │  │
│  │  └── Image:   sd-3.5-large, flux-2-klein, qwen   │  │
│  └───────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

## Models

| Category   | Model                          | Provider    |
|------------|--------------------------------|-------------|
| General    | `kimi-k2.6`                    | NVIDIA NIM  |
| General    | `deepseek-v4-pro`              | NVIDIA NIM  |
| General    | `glm-5.1`                      | NVIDIA NIM  |
| Coding     | `qwen3-coder-480b-a35b`        | NVIDIA NIM  |
| Coding     | `nemotron-3-super-120b`        | NVIDIA NIM  |
| Image Gen  | `stable-diffusion-3.5-large`   | NVIDIA NIM  |
| Image Gen  | `flux-2-klein-4b`              | NVIDIA NIM  |
| Image Gen  | `qwen-image`                   | NVIDIA NIM  |

## Required Secrets

Set these in your Hugging Face Space **Settings → Secrets**:

| Secret            | Required | Description                                      |
|-------------------|----------|--------------------------------------------------|
| `NVIDIA_API_KEY`  | ✅       | Your NVIDIA NIM API key from build.nvidia.com    |
| `GEMINI_API_KEY`  | ⚠️       | Google Gemini API key for web search (grounding)    |
| `GATEWAY_TOKEN`   | ❌       | Gateway auth token (defaults to `openclaw-hf-spaces`) |

> **Note on Web Search:** Uses **Gemini 3.1 Flash-Lite** for Google Search grounding (5,000 free prompts/month on the free tier). The `GEMINI_API_KEY` is your Google AI Studio key from [aistudio.google.com](https://aistudio.google.com/apikey).

## Quick Start

1. **Fork/clone** this Space
2. **Add secrets** in Space settings (`NVIDIA_API_KEY` is required)
3. **Wait** for the build to complete
4. **Open** the Space URL → you'll see the OpenClaw Control UI
5. **Chat** with any of the configured models

## Local Development

```bash
# Create .env file
echo "NVIDIA_API_KEY=nvapi-xxxx" > .env
echo "GEMINI_API_KEY=AIza-xxxx" >> .env

# Build and run
docker compose up --build

# Access at http://localhost:7860
```

## File Structure

```
.
├── Dockerfile          # Ubuntu 24.04 + Node.js 24 + OpenClaw
├── docker-compose.yml  # Local development compose
├── openclaw.json       # OpenClaw configuration (NIM models, gateway, tools)
├── entrypoint.sh       # Startup: renders config from env vars, launches gateway
└── README.md           # This file
```

## Gateway Access

- **Control UI:** `https://<your-space>.hf.space`
- **Auth Token:** Value of `GATEWAY_TOKEN` secret (default: `openclaw-hf-spaces`)
- **API:** `https://<your-space>.hf.space/v1/chat/completions` (OpenAI-compatible)

## License

OpenClaw is open source. See [github.com/openclaw/openclaw](https://github.com/openclaw/openclaw) for details.
