FROM pytorch/pytorch:2.9.1-cuda12.6-cudnn9-devel

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

# 2. Install uv (Python package manager)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:${PATH}"

# 3. Upgrade pip
RUN pip3 install --no-cache-dir --upgrade pip

# 4. Install Claude Code CLI
RUN curl -fsSL https://claude.ai/install.sh | bash

# 5. Install 
RUN { \
    echo "alias ll='ls -alF'"; \
    echo "alias claude-fast='claude --dangerously-skip-permissions'"; \
    echo "alias codex-fast='codex --dangerously-bypass-approvals-and-sandbox'"; \
} >> /root/.bashrc 

# 5. Create entrypoint script
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh
COPY . /app/builder

WORKDIR /workspace
ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["/bin/bash"]