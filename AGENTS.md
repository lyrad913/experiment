## 프로젝트 목적
- 이 저장소는 `<project_goal>`을 위한 연구/개발 프로젝트다.
- 핵심 산출물은 보통 다음을 포함한다:
  - 학습/평가 코드
  - 재현 가능한 실험 설정
  - 결과 요약 및 보고용 산출물 md 파일
- 기본 운영 원칙:
  - 재현성 우선
  - 실험 설정과 결과의 추적 가능성 보장
  - 최소 변경 단위로 실험 비교 가능하게 유지
  - 코드와 문서가 같은 구조를 공유하도록 유지

## 기술 스택
- Language: `Python`
- Package/Env: `uv` (`pyproject.toml` + `uv.lock`이 환경의 단일 진실 원천)
- Main Framework: `<main_framework>`
- Testing: `pytest`
- 실험 실행은 스크립트/모듈 기반으로 단순하게 유지한다.

프로젝트별 기본값 예시:
- Python version: `.python-version` 참조 (uv 관리 Python)
- 주요 라이브러리: `<core_dependencies>`
- 기본 디바이스 정책: `<device_policy>`

## 프로젝트 구조
- `papers/` : 논문, 초록 저장소
  - `papers/pdf/open`: 인터넷에서 자동으로 다운받을 수 있는 논문 저장소
  - `papers/pdf/closed`: 인터넷에서 자동으로 다운이 안 되고, 따로 다운받아야 하는 논문
  - `papers/open_abstract`: 모델 정의
  - `papers/papers.csv` : paper 요약된 csv 
- `builder/`: 컨테이너/실행 환경 정의 (`Dockerfile`, compose 파일, env 예시)
- `data/`: 데이터 저장소, raw 데이터를 제외한 모든 데이터는 00으로 01,02 이런 식으로 작성한다.
  - `data/raw`: 원본 또는 staging 입력
  - `data/interim`: 중간 산출물
  - `data/processed`: 학습/평가 직접 입력
  - `data/scripts`: 데이터 변환 스크립트, 데이터 변환스크립트는 00으로 시작하여 01,02 이런 식으로 작성한다.
  - `data/scripts/model`: 고통으로 사용될 데이터 변환스크립트, ex. 다른 레포에서 갖고 온 torch 모델 등
- `notebooks/`: 탐색/분석 노트북
- `src/`: 핵심 코드
  - `src/data`: 로딩, 검증, 전처리
  - `src/models`: 모델 정의
  - `src/train`: 학습 엔트리 및 루프
  - `src/eval`: 평가 및 리포팅
  - `src/utils`: 공통 유틸리티
- `experiments/`: 실험 단위 디렉터리, 실험은 00으로 시작하여 01,02 이런 식으로 작성한다. 실험 목적이 변경된 경우에만 새로운 폴더를 생성한다. 같은 목적의 실험의 경우 하위 폴더를 만들어서 00으로 시작하여 01,02로 작성한다. 또한 재실행을 위한 sh파일, py파일이 포함되어 있다.
  - `experiments/readme.md` : 각 실험에 대한 목적, 방법 등이 간략하게 적혀있다.
  - `experiments/xx_{experiment_name}/readme.md` : 각 실험에 대한 목적, 방법, 결과 등이 적혀있다.
  - `experiments/xx_{experiment_name}/xx_{experiment_name}/config.json`
  - `experiments/xx_{experiment_name}/xx_{experiment_name}/outputs` : 산출물
  - `experiments/xx_{experiment_name}/xx_{experiment_name}/README.md` : 목적, 가설, data source, key settings, how to run, expected results, Reproducibility, 최종 결과 설명 등에 대해서 작성된 매우 자세한 실험 설명서

- `docs/` : 실험계획서, plan 저장소
- `refs/` : 다른 github repo
- `tests/`: 단위/통합 테스트

구조 운영 원칙:
- 코드, 설정, 문서는 가능한 한 같은 실험 단위로 묶는다.
- 데이터 원본은 직접 수정하지 않고, 중간 산출물과 가공 산출물을 분리한다.
- 일회성 스크립트보다 재실행 가능한 모듈/스크립트 엔트리를 우선한다.

## 실험 디렉터리 운영 규칙
- 각 실험은 `experiments/<experiment_name>/<inner_experiment_name>/` 구조로 관리한다.
- 실험 묶음 폴더는 반드시 두 자리 번호 prefix를 사용한다.
  - 예시: `experiments/00_regression_loss_ablation/`, `experiments/01_snubh_hypotension_baselines/`
- 같은 묶음 안에서 사람이 직접 만드는 하위 실험 폴더도 가능한 한 두 자리 번호 prefix를 사용한다.
  - 예시: `00_tabular_baseline/`, `01_waveform_baseline/`, `02_multimodal_baseline/`
- 자동 생성되는 fold/seed/protocol 하위 폴더는 예외로 둘 수 있다.
  - 예시: `repeat_01_fold_01/`, `lopo_01_<patient_id>/`
- smoke, diagnose, ablation, pilot도 예외 없이 묶음 폴더 아래에 둔다.
  - 예시: `experiments/90_diagnostics/00_repeated_cv_smoke/`
- 각 실험 디렉터리에는 최소 다음 항목을 둔다:
  - `README.md`
  - 하나 이상의 설정 파일 (`*.json`, `*.yaml` 등)
  - `outputs/`
- 각 실험의 `README.md`에는 최소 다음을 기록한다:
  - 실험 목적과 가설
  - 비교 기준 또는 baseline
  - 사용 데이터 소스
  - 핵심 설정값
  - 실행 명령
  - 출력 경로
  - 재현 절차와 seed
- 각 실험의 결과물은 해당 실험 폴더 내부 `outputs/`에 저장한다.

권장 규칙:
- 신규 실험은 기존 전역 설정 파일보다 실험 디렉터리 내부 설정을 우선한다.
- 논문/보고서 표에 반영하는 결과는 최종 요약 파일만 보지 말고 원본 metric artifact까지 함께 확인한다.
- run 단위 `README.md`는 해당 묶음의 목적, 공통 설정, 핵심 결과 해석을 요약하는 인덱스 역할을 하도록 유지한다.
- 새 top-level 실험 묶음을 만들면 `AGENTS.md`의 `현재 실험 폴더 인덱스`에 폴더 목적을 바로 추가한다.
- `AGENTS.md`에는 최신 metric을 적지 않고, 폴더의 역할과 실험 범위만 적는다.
- `AGENTS.md`에는 top-level 실험 묶음의 목적만 기록하고, 하위 실험 설명은 각 묶음 폴더의 `README.md`에서 관리한다.
- 기존 실험을 확장하거나 재실행할 때, 묶을 수 있는 실험이면 새 번호 prefix 묶음으로 정리한 뒤 실행하는 것을 기본 원칙으로 한다.

## 데이터 운영 원칙
- 기본 데이터 루트는 `<data_root>`로 명시한다.
- 데이터셋, split, 버전, 전처리 규칙은 코드와 문서에서 같은 이름으로 기록한다.
- 파일명 규칙이 있으면 문서에 고정하고, 실험 로그에서도 동일한 이름을 사용한다.
- 학습/평가 직접 입력 파일과 중간 변환 산출물은 구분한다.
- 큰 데이터셋을 다룰 때는 다음을 문서화한다:
  - 저장 위치
  - 포맷
  - 생성 절차
  - 직접 사용 대상인지 중간 산출물인지 여부
- 로더가 여러 포맷 또는 fallback 경로를 지원하면 그 우선순위를 명시한다.

주의:
- 환경에 기본 설치되지 않은 데이터 의존성(`pyarrow`, `pandas`, `duckdb` 등)이 있다면 별도 명시한다.
- 컬럼 스키마, row 수, split 기준, version은 가능한 한 코드가 아닌 문서와 설정에도 남긴다.

## 개발 및 실행 명령
작업 디렉터리:
- `cd <repo_root>`

환경 재현:
- `uv sync --locked` : `uv.lock` 그대로 `.venv`를 재현한다. 컨테이너 시작 시 entrypoint가 자동 실행한다.
- `.venv`를 직접 activate하지 않고 `uv run ...`으로 실행한다.

의존성 관리:
- `uv add <package_name>` / `uv remove <package_name>`
- 개발 전용 도구: `uv add --dev <package_name>`
- `pip install`, `uv pip install`은 사용하지 않는다. lock에 기록되지 않아 재현이 깨진다.
- `torch`, `torchvision`, `torchaudio`는 `pyproject.toml`의 `[tool.uv.sources]`로 PyTorch CUDA 인덱스(`pytorch-cu130`)에 고정되어 있다. 버전 변경도 `uv add torch==<version>`으로 한다.
- CUDA 버전을 바꿀 때는 `builder/Dockerfile` 베이스 이미지와 `pyproject.toml`의 인덱스 URL을 함께 바꾼다.

uv 캐시 디렉터리:
- sandbox 또는 권한 이슈가 있는 환경에서는 `UV_CACHE_DIR=/tmp/uv-cache`를 사용한다.

학습 예시:
- `uv run python -m <train_module> <config_path>`

평가 예시:
- `uv run python -m <eval_module> <config_path>`

테스트:
- `uv run pytest -q`

운영 원칙:
- 직접 `python ...`보다 `uv run ...`을 우선한다.
- `pyproject.toml`을 바꾸면 `uv.lock`도 같은 커밋에 포함한다.
- 실행 명령은 `README.md`와 실험 설정 파일에 함께 남긴다.
- 공용 실행 진입점은 가능한 한 `uv run python -m <module>` 형태로 통일한다.

## 코딩 스타일
- PEP 8 준수, 4-space indentation
- 함수/변수는 `snake_case`
- 클래스는 `PascalCase`
- 상수는 `UPPER_SNAKE_CASE`
- 과도한 리팩터링보다 목적이 분명한 작은 변경을 우선한다.
- 핵심 실험 로직은 긴 주석보다 함수 분리로 명확화한다.
- 설정값은 코드 하드코딩보다 설정 파일이나 dataclass에서 관리한다.

## 모델/학습 코드 가이드라인
- 주요 텐서 변환 이후 shape 주석을 남긴다.
- 초기 구현 단계에서는 assert 기반 shape validation을 적극 사용한다.
- 입력, 인코더 출력, 헤드 출력, loss 직전 텐서는 shape가 쉽게 드러나게 작성한다.
- 단일 디바이스 기준 기본 정책을 문서화하고, 멀티 GPU가 비주류라면 명시적으로 제외한다.

권장 패턴:
- `# x: [batch, n_tokens, d_model]`
- `assert x.dim() == 3 and x.size(-1) == d_model`

추가 권장 사항:
- augmentation, threshold, sampler, loss 조합은 설정 파일에서 고정한다.
- 평가 시 학습과 다른 규칙이 있다면 별도 옵션으로 분리하고 문서에 명시한다.

## 인자 파싱 규칙
- `argparse.ArgumentParser` 직접 사용보다 `@dataclass` 기반 파싱을 우선한다.
- 프로젝트가 Hugging Face 스타일과 잘 맞으면 `HfArgumentParser` 사용을 권장한다.
- 인자 그룹은 역할별로 분리한다.
  - `ModelArguments`
  - `DataArguments`
  - `TrainingArguments` 또는 프로젝트 전용 `TrainingConfig`
- 각 dataclass의 유효성 검사는 `__post_init__`에서 수행한다.
- CLI 인자와 설정 파일 파싱을 모두 지원한다.

예시 패턴:
```python
from dataclasses import dataclass
from transformers import HfArgumentParser
import os
import sys


def main():
    parser = HfArgumentParser((ModelArguments, DataArguments, TrainingConfig))

    if len(sys.argv) == 2 and sys.argv[1].endswith(".json"):
        model_args, data_args, train_args = parser.parse_json_file(
            json_file=os.path.abspath(sys.argv[1])
        )
    else:
        model_args, data_args, train_args = parser.parse_args_into_dataclasses()
```

## 테스트 가이드
- 테스트 프레임워크는 `pytest`를 사용한다.
- 파일명은 `tests/test_<module>.py` 형태를 따른다.
- 최소 검증 대상:
  - 데이터 로딩/스키마 검증
  - split 및 leakage 방지 규칙
  - sampler 또는 batching 로직
  - metric 계산
  - 학습 step 또는 추론 step 기본 동작
- 새 테스트 명령 또는 옵션을 추가하면 `README.md`와 에이전트 문서를 함께 갱신한다.

권장 규칙:
- 작은 유닛 테스트와 짧은 end-to-end smoke test를 같이 둔다.
- seed 고정이 필요한 테스트는 명시적으로 고정한다.
- 성능 수치 그 자체보다 계약 위반 여부를 우선 검증한다.

## 문서화 규칙
- 저장소 루트 `README.md`에는 프로젝트 목적, 설치, 실행, 데이터 개요를 기록한다.
- `experiments/README.md`에는 실험 묶음별 해석과 참조 경로를 요약한다.
- 실험별 `README.md`에는 실행 방법과 결과 해석의 최소 단위를 남긴다.
- 재현에 필요한 핵심 파라미터는 코드 주석이 아니라 설정 파일과 문서 양쪽에 남긴다.
- `AGENTS.md`에는 top-level 실험 묶음의 의미를 인덱스로 유지한다.
- 하위 실험 설명은 `AGENTS.md`가 아니라 해당 묶음 폴더의 `README.md`에서 관리한다.
- `src/models`와 `src/train`의 파일 인덱스는 `AGENTS.md`에 짧게 유지한다.
- `src/models/README.md`와 `src/train/README.md`에는 각 파일의 역할과 사용 맥락을 더 자세히 기록한다.
- 새 실험 묶음이 생기면 다음 3가지는 함께 갱신한다:
  - `experiments/<NN_name>/README.md`
  - 필요 시 해당 묶음 내부 설정 파일
  - `AGENTS.md`의 `현재 실험 폴더 인덱스`
- `src/models` 또는 `src/train`에 파일을 추가, 제거, 이름 변경하면 다음 2가지를 함께 갱신한다:
  - `AGENTS.md`의 해당 파일 인덱스
  - 해당 폴더의 `README.md`

## 커밋 규칙
- 커밋 메시지는 짧고 명령형으로 한국어로 작성한다.
- 하나의 실험 가설 또는 하나의 코드 변경 단위로 커밋을 나눈다.
- 커밋는 최소 다음을 포함한다:
  - 변경 요약
  - 영향 범위
  - 재현 절차
  - 설정/환경 변수 변경 사항
  - 테스트 또는 핵심 결과 요약

## 보안 및 설정
- 비밀키와 토큰은 커밋하지 않는다.
- 시크릿은 `<env_file>` 또는 로컬 환경변수로만 관리한다.
- 환경 기본값을 바꾸면 관련 compose 파일, 예시 env, 문서를 함께 갱신한다.
- 외부 서비스 의존성이 있으면 필요한 환경변수 이름과 최소 권한 원칙을 기록한다.

## 재현성 체크리스트
- split 기준 ID 고정
- 전처리 및 라벨링 규칙 고정
- seed 기록
- 핵심 하이퍼파라미터 설정 파일에 고정
- 결과 보고 형식 통일
- 데이터 버전 및 코드 버전 추적 가능하게 유지
- main 결과와 부록/탐색 결과를 분리해서 기록

## 유지보수 원칙
- 이 문서는 현재 프로젝트의 상태 보고서가 아니라 작업 규칙 문서로 유지한다.
- 실제 파일명, 최신 결과, 특정 날짜, 특정 실험 결론은 가능하면 별도 `README.md` 또는 실험 문서로 분리한다.
- 범용 규칙과 프로젝트 고유 규칙이 섞이기 시작하면, 고유 규칙은 별도 섹션 또는 별도 문서로 이동한다.

## 현재 실험 폴더 인덱스

추가 운영 규칙:
- 위 인덱스에 없는 top-level 실험 폴더를 새로 만들면 안 된다. 새 폴더를 만들 경우 먼저 번호 prefix 이름을 정하고, 생성 직후 이 섹션에 추가한다.
- 기존 번호 없는 legacy 폴더가 있으면 가능하면 번호 prefix 묶음으로 이동한 뒤 인덱스를 갱신한다.



