#!/bin/bash
set -e

# 환경 변수 확인
if [ -z "$MYSQL_HOST" ] || [ -z "$MYSQL_USER" ] || [ -z "$MYSQL_PASSWORD" ] || [ -z "$MYSQL_DATABASE" ]; then
    echo "필수 환경 변수가 설정되지 않았습니다."
    echo "필요한 환경 변수: MYSQL_HOST, MYSQL_USER, MYSQL_PASSWORD, MYSQL_DATABASE"
    exit 1
fi

# 백업 디렉토리 확인 및 생성
if [ ! -d "$BACKUP_DIR" ]; then
    echo "백업 디렉토리가 존재하지 않습니다: $BACKUP_DIR"
    echo "볼륨이 제대로 마운트되었는지 확인해주세요."
    exit 1
fi

# 현재 시간을 파일명에 포함
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/${BACKUP_FILENAME_PREFIX}_${MYSQL_DATABASE}_${TIMESTAMP}.sql"

echo "MariaDB 데이터베이스 덤프를 시작합니다..."
echo "호스트: $MYSQL_HOST"
echo "데이터베이스: $MYSQL_DATABASE"
echo "백업 파일: $BACKUP_FILE"

# mysqldump 명령 실행
mysqldump -h "$MYSQL_HOST" -P "$MYSQL_PORT" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" \
    --single-transaction --quick --lock-tables=false \
    "$MYSQL_DATABASE" > "$BACKUP_FILE"

# 결과 확인
if [ $? -eq 0 ]; then
    echo "데이터베이스 덤프가 성공적으로 완료되었습니다."
    echo "백업 파일: $BACKUP_FILE"
    echo "파일 크기: $(du -h "$BACKUP_FILE" | cut -f1)"
else
    echo "데이터베이스 덤프 중 오류가 발생했습니다."
    exit 1
fi

# 전체 데이터베이스 덤프 (지정된 데이터베이스가 "all"인 경우)
if [ "$MYSQL_DATABASE" = "all" ]; then
    BACKUP_FILE="${BACKUP_DIR}/${BACKUP_FILENAME_PREFIX}_all_databases_${TIMESTAMP}.sql"
    echo "모든 데이터베이스 덤프를 시작합니다..."
    
    mysqldump -h "$MYSQL_HOST" -P "$MYSQL_PORT" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" \
        --single-transaction --quick --lock-tables=false \
        --all-databases > "$BACKUP_FILE"
    
    if [ $? -eq 0 ]; then
        echo "모든 데이터베이스 덤프가 성공적으로 완료되었습니다."
        echo "백업 파일: $BACKUP_FILE"
        echo "파일 크기: $(du -h "$BACKUP_FILE" | cut -f1)"
    else
        echo "모든 데이터베이스 덤프 중 오류가 발생했습니다."
        exit 1
    fi
fi

echo "백업 프로세스가 완료되었습니다." 