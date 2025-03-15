#!/bin/bash
set -e

# 현재 디렉토리가 kubernetes 폴더인지 확인
if [ "$(basename $(pwd))" != "kubernetes" ]; then
    echo "이 스크립트는 kubernetes 폴더에서 실행해야 합니다."
    exit 1
fi

# 환경 변수 파일 로드
if [ -f ".env" ]; then
    echo "환경 변수 파일(.env)을 로드합니다."
    source .env
else
    echo "환경 변수 파일(.env)이 없습니다. 기본값을 사용합니다."
fi

# 기본값 설정
MARIADB_HOST=${MARIADB_HOST:-mariadb-service}
MARIADB_PORT=${MARIADB_PORT:-3306}
MARIADB_DATABASE=${MARIADB_DATABASE:-mydatabase}
BACKUP_STORAGE_SIZE=${BACKUP_STORAGE_SIZE:-10Gi}
LOCAL_BACKUP_PATH=${LOCAL_BACKUP_PATH:-$(pwd)/../local-backups}

# 로컬 백업 경로가 존재하는지 확인하고 생성
if [ ! -d "$LOCAL_BACKUP_PATH" ]; then
    echo "로컬 백업 경로($LOCAL_BACKUP_PATH)가 존재하지 않습니다. 경로를 생성합니다."
    mkdir -p "$LOCAL_BACKUP_PATH"
fi

# 쿠버네티스 설정 파일 생성
echo "쿠버네티스 설정 파일을 생성합니다..."

# CronJob 생성
cat k8s-cronjob.yaml.template | \
    sed "s|\${MARIADB_HOST}|$MARIADB_HOST|g" | \
    sed "s|\${MARIADB_PORT}|$MARIADB_PORT|g" | \
    sed "s|\${MARIADB_DATABASE}|$MARIADB_DATABASE|g" | \
    sed "s|\${LOCAL_BACKUP_PATH}|$LOCAL_BACKUP_PATH|g" \
    > k8s-cronjob.yaml

# PVC 생성
cat backup-pvc.yaml.template | \
    sed "s|\${BACKUP_STORAGE_SIZE}|$BACKUP_STORAGE_SIZE|g" \
    > backup-pvc.yaml

echo "설정 파일 생성이 완료되었습니다."
echo "  - k8s-cronjob.yaml"
echo "  - backup-pvc.yaml"
echo ""
echo "로컬 백업 경로: $LOCAL_BACKUP_PATH"
echo ""
echo "시크릿은 별도로 생성해야 합니다:"
echo "MARIADB_USER=사용자명 MARIADB_PASSWORD=비밀번호 ./create-secrets.sh" 