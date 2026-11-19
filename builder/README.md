# builder

Rootless Docker 서버에서 실험 컨테이너를 띄우기 위한 파일 모음.
컨테이너 최초 실행 시 workspace에 `src/`가 없으면 `JINAILAB/experiment`를 pull하고, `builder/`를 이 폴더 내용으로 통째로 교체한다.

## 구성

| 파일 | 역할 |
|---|---|
| `Dockerfiles/Dockerfile.torch` | `pytorch/pytorch:2.9.1-cuda12.6-cudnn9-devel` 기반. torch가 이미지에 포함 |
| `Dockerfiles/Dockerfile.cuda` | `nvidia/cuda:13.0.2-cudnn-devel-ubuntu22.04` 기반. torch 없음, uv 관리 Python 3.12 |
| `docker-compose-torch.yml` | `Dockerfile.torch`로 컨테이너 기동 |
| `docker-compose-uv.yml` | `Dockerfile.cuda`로 컨테이너 기동 + `uv-cache` 볼륨 |
| `entrypoint.sh` | git 설정, 최초 실행 시 workspace 초기화 |
| `env/example.env` | 사용자별 env 파일 샘플 |
| `new-user-rootless.sh` | (관리자용) 신규 유저에 rootless docker 세팅 |

## 1. env 파일 만들기

```bash
cd /data/common/experiment/builder
cp env/example.env env/<user_id>.env
```

| 변수 | 필수 | 설명 |
|---|---|---|
| `USER_ID` | O | 서버 계정 |
| `PROJECT_NAME` | O | 프로젝트 및 컨테이너 이름 (대소문자, `-`, `_`만) |
| `GIT_USER_NAME`, `GIT_USER_EMAIL` | 권장 | 컨테이너 안 git 설정 |
| `WANDB_API_KEY`, `HF_TOKEN`, `OPENAI_API_KEY` | 선택 | API 키 |
| `USER_WORKDIR` | - | `/data/${USER_ID}/${PROJECT_NAME}`로 자동 지정. 수정 불필요 |

`env/*.env`는 `.dockerignore`로 이미지와 workspace에 복사되지 않는다 (`example.env` 제외).

## 2. 컨테이너 기동

```bash
cd /data/common/experiment/builder

# torch 포함 이미지
docker compose -f docker-compose-torch.yml --env-file env/<user_id>.env up --build -d

# CUDA + uv 이미지 (torch는 직접 설치)
docker compose -f docker-compose-uv.yml --env-file env/<user_id>.env up --build -d
```

compose 파일의 `name: ${PROJECT_NAME}` 덕분에 `-p` 옵션은 필요 없다.

## 3. 접속

```bash
docker exec -it <PROJECT_NAME> /bin/bash
```

## 4. 종료

```bash
docker compose -f docker-compose-<torch|uv>.yml --env-file env/<user_id>.env down
```
