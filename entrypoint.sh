#!/usr/bin/env bash
# =============================================================================
# entrypoint.sh — Render config from env vars, then start OpenClaw Gateway
# =============================================================================
set -euo pipefail

TEMPLATE="/etc/openclaw/openclaw.json.template"
DEST="${HOME}/.openclaw/openclaw.json"
WORKSPACE="${HOME}/.openclaw/workspace"

# ---------- Validate required env vars ---------------------------------------
if [ -z "${NVIDIA_API_KEY:-}" ]; then
    echo "ERROR: NVIDIA_API_KEY is not set. Please provide it as a Hugging Face Secret."
    exit 1
fi

# ---------- Ensure workspace directory exists --------------------------------
mkdir -p "${WORKSPACE}"

# ---------- Render config: substitute API key placeholders -------------------
sed \
    -e "s|__NVIDIA_API_KEY__|${NVIDIA_API_KEY}|g" \
    -e "s|__GEMINI_API_KEY__|${GEMINI_API_KEY:-}|g" \
    -e "s|__GATEWAY_TOKEN__|${GATEWAY_TOKEN:-openclaw-hf-spaces}|g" \
    "${TEMPLATE}" > "${DEST}"

# ---------- Create minimal workspace files if missing ------------------------
if [ ! -f "${WORKSPACE}/SOUL.md" ]; then
    cat > "${WORKSPACE}/SOUL.md" << 'SOUL'
# SOUL.md
You are an AI assistant running on Hugging Face Spaces via OpenClaw.
Be helpful, concise, and resourceful.
SOUL
fi

if [ ! -f "${WORKSPACE}/AGENTS.md" ]; then
    cat > "${WORKSPACE}/AGENTS.md" << 'AGENTSFILE'
# AGENTS.md
This is a fresh OpenClaw instance on Hugging Face Spaces.
AGENTSFILE
fi

# ---------- Announce startup -------------------------------------------------
echo "=============================================="
echo "  OpenClaw Gateway — Hugging Face Spaces"
echo "  Port: 7860"
echo "  Models: NVIDIA NIM (kimi, deepseek, glm, qwen, nemotron)"
echo "  Search:  Gemini 3.1 Flash-Lite (Google Search grounding)"
echo "=============================================="

# ---------- Launch OpenClaw Gateway ------------------------------------------
# --port 7860 for HF Spaces compatibility
# --bind lan so it listens on 0.0.0.0 (not just loopback)
exec openclaw gateway run \
    --port 7860 \
    --bind lan \
    --verbose
