FROM debian:bullseye-slim

# 필요한 패키지 설치
RUN apt-get update && apt-get install -y \
    mariadb-client \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 패키지가 설치되었는지 확인
RUN which mysqldump || (echo "mysqldump not found" && exit 1)

# 작업 디렉토리 생성
WORKDIR /app

# 스크립트 추가
COPY mariadb-dump.sh /app/
RUN chmod +x /app/mariadb-dump.sh

# 볼륨 마운트 포인트 생성
VOLUME /backup

# 환경 변수 설정
ENV MYSQL_HOST=localhost \
    MYSQL_PORT=3306 \
    MYSQL_USER=root \
    MYSQL_PASSWORD=password \
    MYSQL_DATABASE=mydatabase \
    BACKUP_DIR=/backup \
    BACKUP_FILENAME_PREFIX=mariadb_backup

# 컨테이너 실행 시 실행되는 명령어
ENTRYPOINT ["/app/mariadb-dump.sh"] 