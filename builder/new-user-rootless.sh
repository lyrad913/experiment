#!/bin/bash
# 신규 유저에게 rootless docker foundation 을 붙인다 (adduser 로 계정 만든 뒤 실행).
# 사용: sudo bash new-user-rootless.sh <user>
# 하는 일: ai_center 그룹 + linger + rootless docker 설치 + data-root(/data) + ACL 제거 + CDI + 검증.
# ⚠️ docker 그룹에는 절대 넣지 않는다 (rootless 는 그룹을 안 쓰고, 넣으면 root 구멍이 열린다).
set -u
U="${1:?사용: new-user-rootless.sh <user>}"
UID_N=$(id -u "$U" 2>/dev/null) || { echo "FATAL: 유저 $U 없음. 먼저 adduser $U"; exit 1; }
RUN=/run/user/$UID_N
asu(){ sudo -u "$U" env XDG_RUNTIME_DIR=$RUN DBUS_SESSION_BUS_ADDRESS=unix:path=$RUN/bus PATH=/usr/bin:/bin:/usr/sbin:/sbin "$@"; }
dk(){ sudo -u "$U" env XDG_RUNTIME_DIR=$RUN "$@"; }
echo "########## $U (uid $UID_N) ##########"

# 0) 전제조건: subuid/subgid (adduser 가 보통 자동 할당). 없으면 멈춘다.
if ! grep -q "^$U:" /etc/subuid || ! grep -q "^$U:" /etc/subgid; then
  echo "FATAL: /etc/subuid|subgid 에 $U 없음. 수동 할당 필요:"
  echo "  usermod --add-subuids 100000000-100065535 --add-subgids 100000000-100065535 $U"
  echo "  (겹치지 않는 65536 크기 대역으로. 이후 재실행)"; exit 1
fi

# 1) 공유 그룹만. docker 그룹은 넣지 않는다.
usermod -aG ai_center "$U" && echo "ai_center 그룹 추가"

# 2) linger (로그아웃해도 데몬 유지 + /run/user/$UID 생성)
loginctl enable-linger "$U"; sleep 1
[ -d "$RUN" ] || { echo "FATAL: $RUN 없음 (세션 미기동)"; exit 1; }

# 3) rootless docker 설치
asu dockerd-rootless-setuptool.sh install --force >/tmp/nu_$U.log 2>&1 && echo "rootless docker 설치 OK" || { echo "설치 실패"; tail -5 /tmp/nu_$U.log; exit 1; }

# 4) data-root(/data) + 상속 ACL 제거 + CDI daemon.json
sudo -u "$U" mkdir -p "/home/$U/.config/docker" "/data/containers/$U/docker"
setfacl -b -k "/data/containers/$U/docker"          # /data default ACL 상속 제거 (apt 깨짐 방지)
sudo -u "$U" tee "/home/$U/.config/docker/daemon.json" >/dev/null <<EOF
{
  "data-root": "/data/containers/$U/docker",
  "features": { "cdi": true },
  "cdi-spec-dirs": ["/etc/cdi", "/var/run/cdi"]
}
EOF
asu systemctl --user restart docker.service; sleep 3

# 5) 검증 6항목
echo "--- 검증 ---"
CTX=$(dk docker context show 2>&1)
ROOT=$(dk docker info --format '{{.DockerRootDir}}' 2>&1)
UIDC=$(dk docker run --rm ubuntu:22.04 id -u 2>/dev/null)
APT=$(dk docker run --rm ubuntu:22.04 sh -c 'apt-get update -qq >/dev/null 2>&1 && apt-get install -y -qq tree >/dev/null 2>&1 && echo OK' 2>/dev/null)
GPU=$(dk docker run --rm --device nvidia.com/gpu=all ubuntu:22.04 nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | wc -l)
OT=/tmp/nu_own_$U; rm -rf $OT; mkdir -p $OT; chmod 777 $OT
dk docker run --rm -v $OT:/w ubuntu:22.04 touch /w/f 2>/dev/null; OWN=$(stat -c '%U:%G' $OT/f 2>/dev/null); rm -rf $OT
echo "[1] context=$CTX  [2] root=$ROOT  [3] uid=$UIDC  [4] apt=$APT  [5] gpu=${GPU}장  [6] 소유권=$OWN"
[ "$CTX" = rootless ] && [ "$ROOT" = "/data/containers/$U/docker" ] && [ "$UIDC" = 0 ] && [ "$APT" = OK ] && [ "${GPU:-0}" -ge 1 ] 2>/dev/null && [ "$OWN" = "$U:$U" ] \
  && echo "===== $U: 6/6 통과 — 완료 =====" || echo "===== $U: 실패 항목 확인 필요 ====="
