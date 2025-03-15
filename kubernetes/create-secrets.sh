#!/bin/bash
set -e

# 환경 변수 확인
if [ -z "$MARIADB_USER" ] || [ -z "$MARIADB_PASSWORD" ]; then
    echo "필수 환경 변수가 설정되지 않았습니다."
    echo "필요한 환경 변수: MARIADB_USER, MARIADB_PASSWORD"
    exit 1
fi

# Base64 인코딩 (쿠버네티스 시크릿용)
USERNAME_BASE64=$(echo -n "$MARIADB_USER" | base64)
PASSWORD_BASE64=$(echo -n "$MARIADB_PASSWORD" | base64)

# 시크릿 생성
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: mariadb-backup-secrets
type: Opaque
data:
  username: $USERNAME_BASE64
  password: $PASSWORD_BASE64
EOF

echo "MariaDB 백업 시크릿이 성공적으로 생성되었습니다." 