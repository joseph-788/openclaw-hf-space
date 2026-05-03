# =============================================================================
# OpenClaw on Hugging Face Spaces — Dockerfile
# Base: Ubuntu 24.04 | Node.js 24 | Python 3.12
# =============================================================================

FROM ubuntu:24.04

LABEL maintainer="openclaw" \
      description="OpenClaw AI Gateway on Hugging Face Spaces"

# ---------- Avoid interactive prompts during package install ------------------
ENV DEBIAN_FRONTEND=noninteractive
ENV HOME=/home/openclaw
ENV OC_HOME=/home/openclaw/.openclaw

# ---------- System packages ---------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates curl wget git sudo gnupg \
        python3 python3-pip python3-venv \
        gettext-base \
    && rm -rf /var/lib/apt/lists/*

# ---------- Node.js 24.x (via NodeSource) ------------------------------------
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# ---------- Create openclaw user with full sudo ------------------------------
RUN useradd -m -s /bin/bash openclaw \
    && echo "openclaw ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/openclaw \
    && chmod 0440 /etc/sudoers.d/openclaw

# ---------- Install OpenClaw globally ----------------------------------------
RUN npm install -g openclaw@latest

# ---------- Prepare OpenClaw directory structure ------------------------------
RUN mkdir -p ${OC_HOME}/workspace /etc/openclaw \
    && chown -R openclaw:openclaw /home/openclaw

# ---------- Copy configuration files -----------------------------------------
COPY openclaw.json /etc/openclaw/openclaw.json.template
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# ---------- Hugging Face Spaces: expose port 7860 ----------------------------
EXPOSE 7860

# ---------- Health check -----------------------------------------------------
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl -sf http://localhost:7860/health || exit 1

# ---------- Switch to openclaw user ------------------------------------------
USER openclaw
WORKDIR /home/openclaw

# ---------- Entrypoint: substitute env vars then launch OpenClaw -------------
ENTRYPOINT ["/entrypoint.sh"]
