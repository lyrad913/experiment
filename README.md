# Experiment Infrastructure

Rootless Docker 기반 DL 실험 환경 구축을 위한 인프라 파일들입니다.

## 📋 구조

```
├── experiment_infra
│   ├── builder
│   │   ├── docker-compose.yml
│   │   ├── Dockerfile
│   │   ├── env
│   │   └── README.md
│   ├── data
│   ├── experiments
│   ├── notebooks
│   └── src
│       ├── data
│       ├── models
│       └── utils
```

## 🚀 사용 방법

### 1. 새 실험 프로젝트 생성

```bash
# 실험 템플릿 복사 (github.com/lyrad913/experiment)
git clone https://github.com/lyrad913/experiment.git

###
cd ./experiment/builder
```

### 2. 인프라 설정

```bash
# Docker Compose V1
docker-compose -f docker-compose.yml --env-file env/.env up --build -d 

# Docker Compose V2
docker compose -f docker-compose.yml --env-file env/.env up --build -d 
```

이 명령어는 다음을 수행합니다:
- `builder/` 폴더 생성
- Dockerfile, docker-compose.yml 복사
- run.sh 실행 스크립트 복사
- env/jyp.env 샘플 생성(예시)

### 3. 환경 설정

**필수 설정(env 파일):**
- `CONTAINER_NAME`: 컨테이너 이름
- `USER_WORKDIR`: workspace 경로 (예: jyp/my_experiment)
- `GIT_USER_NAME`, `GIT_USER_EMAIL`: Git 설정

**선택 설정:**
- `GPU_DEVICES`: 사용할 GPU (all, 0, 0,1 등)
- `WANDB_API_KEY`: Weights & Biases API 키
- `HF_TOKEN`: HuggingFace 토큰
- 그 외 환경변수 등등

### 5. 컨테이너 접속

```bash
# Docker
docker exec -it <CONTAINER_NAME> /bin/bash
```

## 🔧 주요 기능

### 자동 템플릿 초기화
컨테이너 최초 실행 시 workspace에 `src/` 폴더가 없으면 자동으로 템플릿을 복사합니다.

### GPU 지원
- Docker: `runtime: nvidia` 사용

### uv 기반 Python 환경
torch를 포함한 모든 Python 패키지는 이미지가 아니라 `pyproject.toml` + `uv.lock`으로 관리합니다.
컨테이너 시작 시 entrypoint가 `uv sync --locked`로 `/workspace/.venv`를 재현합니다.

```bash
# 패키지 추가 (pyproject.toml, uv.lock 자동 갱신)
uv add numpy pandas

# 스크립트 실행
uv run python -m src.train.<module> <config_path>
```

- torch / torchvision / torchaudio는 PyTorch `cu130` 인덱스에서 받습니다 (`pyproject.toml`의 `[tool.uv.sources]`).
- uv 다운로드 캐시는 `uv-cache` 볼륨에 유지되어 컨테이너를 다시 만들어도 재다운로드하지 않습니다.

### 볼륨 마운트
- Host: `/data/${USER_WORKDIR}`
- Container: `/workspace`

## 📦 포함된 패키지

**Base Image:** `nvidia/cuda:13.0.2-cudnn-devel-ubuntu22.04`

**시스템 패키지:**
- 개발 도구: git, curl, wget, tmux, nano, htop
- 빌드 도구: build-essential, ninja
- 한글 폰트: Nanum (matplotlib 기본 폰트로 설정)
- Node.js 20, codex, Claude Code

**Python 도구:**
- uv (최신) + uv 관리 Python 3.12.13
