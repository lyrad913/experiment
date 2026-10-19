# torch는 uv가 프로젝트 .venv에 설치한다 (pyproject.toml / uv.lock 기준).
# 이미지는 CUDA 툴킷 + 시스템 도구 + uv + uv 관리 Python만 제공한다.
FROM nvidia/cuda:13.0.2-cudnn-devel-ubuntu22.04

# 0. Locale (Korean UTF-8)
RUN apt-get update && apt-get install -y --no-install-recommends \
    locales \
    && rm -rf /var/lib/apt/lists/* \
    && sed -i 's/^# *\(ko_KR.UTF-8 UTF-8\)/\1/' /etc/locale.gen \
    && locale-gen \
    && update-locale LANG=ko_KR.UTF-8 LC_ALL=ko_KR.UTF-8

ENV LANG=ko_KR.UTF-8
ENV LC_ALL=ko_KR.UTF-8
ENV IS_SANDBOX=1

# 0.5 Timezone (Asia/Seoul)
ENV TZ=Asia/Seoul
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends tzdata \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 1. Install System Dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    htop unzip git curl wget tmux nano \
    build-essential ninja-build \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 1.1 Korean fonts for matplotlib (plt 한글 깨짐 방지)
RUN apt-get update && apt-get install -y --no-install-recommends \
    fontconfig \
    fonts-nanum fonts-nanum-coding fonts-nanum-extra \
    && fc-cache -fv \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# matplotlib 기본 폰트를 NanumGothic으로 지정 (모든 matplotlib 프로세스에 적용)
RUN mkdir -p /etc/matplotlib \
    && printf 'font.family: NanumGothic\naxes.unicode_minus: False\n' > /etc/matplotlib/matplotlibrc
ENV MATPLOTLIBRC=/etc/matplotlib

# 1.5 Install Node.js + npm (for codex)
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates gnupg \
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" > /etc/apt/sources.list.d/nodesource.list \
    && apt-get update && apt-get install -y --no-install-recommends nodejs \
    && npm -v && node -v \
    && npm i -g @openai/codex \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 2. Install uv (최신) + uv 관리 Python (버전은 .python-version과 맞춘다)
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/local/bin/
# - 캐시(/root/.cache/uv)와 /workspace 볼륨은 파일시스템이 달라 hardlink 불가 → copy
# - 시스템 Python 대신 uv가 받은 Python만 사용
ENV UV_LINK_MODE=copy \
    UV_PYTHON_PREFERENCE=only-managed \
    UV_PYTHON_INSTALL_DIR=/opt/uv/python
RUN uv python install 3.12.13

# 4. Install Claude Code CLI
RUN curl -fsSL https://claude.ai/install.sh | bash
ENV PATH="/root/.local/bin:${PATH}"

# 5. Aliases
RUN { \
    echo "alias ll='ls -alF'"; \
    echo "alias claude-fast='claude --dangerously-skip-permissions'"; \
    echo "alias codex-fast='codex --dangerously-bypass-approvals-and-sandbox'"; \
} >> /root/.bashrc

# 6. Entrypoint
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh
COPY . /app/builder

WORKDIR /workspace
ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["/bin/bash"]
