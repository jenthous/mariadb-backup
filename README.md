# MariaDB 데이터베이스 백업 도구

쿠버네티스 CronJob을 사용하여 MariaDB 데이터베이스의 주기적인 백업을 수행하는 도구입니다.

## 프로젝트 구조

```
.
├── kubernetes/
│   ├── k8s-cronjob.yaml.template     # CronJob 템플릿 파일
│   ├── backup-pvc.yaml.template      # PVC 템플릿 파일
│   ├── mariadb-secrets.yaml.template # 시크릿 템플릿 파일
│   ├── .env.example                  # 쿠버네티스 환경 변수 예제
│   ├── create-secrets.sh             # 시크릿 생성 스크립트
│   └── generate-k8s-configs.sh       # 환경 변수로 설정 파일 생성 스크립트
├── docker/
│   ├── Dockerfile                    # 백업 도커 이미지 빌드 파일
│   ├── mariadb-dump.sh               # 백업 수행 스크립트
│   ├── docker-compose.yml            # 도커 컴포즈 설정 파일
│   └── .env.example                  # 도커 환경 변수 예제 파일
├── .gitignore                        # Git 제외 파일 설정
└── README.md                         # 현재 파일
```

## 1. 환경 변수 설정

민감한 정보를 보호하고 유연한 설정을 위해 환경 변수를 사용합니다.

### Kubernetes 환경 변수

```bash
cd kubernetes
cp .env.example .env
```

.env 파일을 열고 MariaDB 연결 정보와 백업 설정을 수정합니다:

```
# MariaDB 접속 정보
MARIADB_USER=실제_사용자명
MARIADB_PASSWORD=실제_비밀번호

# 백업 설정
MARIADB_HOST=mariadb-service
MARIADB_PORT=3306
MARIADB_DATABASE=mydatabase  # 특정 DB 또는 'all'

# 스토리지 설정
BACKUP_STORAGE_SIZE=10Gi
```

## 2. 도커 이미지 빌드

백업 작업을 수행할 도커 이미지를 빌드합니다:

```bash
cd docker
docker build -t mariadb-backup .
```

로컬 레지스트리나 도커 허브에 이미지를 푸시할 수 있습니다:

```bash
# 예: 도커 허브에 푸시
docker tag mariadb-backup username/mariadb-backup:latest
docker push username/mariadb-backup:latest
```

## 3. 쿠버네티스 설정 파일 생성

환경 변수를 사용하여 쿠버네티스 설정 파일을 생성합니다:

```bash
cd kubernetes
./generate-k8s-configs.sh
```

이 스크립트는 템플릿 파일을 환경 변수와 함께 처리하여 실제 설정 파일을 생성합니다.

## 4. 쿠버네티스 시크릿 생성

데이터베이스 접속 정보를 담은 시크릿을 생성합니다:

```bash
cd kubernetes
MARIADB_USER=실제_사용자명 MARIADB_PASSWORD=실제_비밀번호 ./create-secrets.sh
```

또는 .env 파일의 값을 사용:

```bash
cd kubernetes
source .env && ./create-secrets.sh
```

## 5. 쿠버네티스 리소스 생성

생성된 설정 파일을 사용하여 쿠버네티스 리소스를 배포합니다:

```bash
cd kubernetes
kubectl apply -f backup-pvc.yaml
kubectl apply -f k8s-cronjob.yaml
```

## 설정 커스터마이징

쿠버네티스 설정을 변경하려면 .env 파일을 수정한 후 generate-k8s-configs.sh 스크립트를 다시 실행하세요.

### 백업 주기 변경

k8s-cronjob.yaml.template 파일에서 schedule 필드를 수정하세요:

```yaml
# 매일 새벽 3시에 실행
schedule: "0 3 * * *"

# 3시간마다 실행
schedule: "0 */3 * * *"
```

## 주의사항

- 환경 변수 파일(.env)과 생성된 쿠버네티스 설정 파일은 .gitignore에 추가되어 Git에 포함되지 않습니다.
- 크론잡 실행 전에 MariaDB 서비스가 쿠버네티스 클러스터에서 실행 중이어야 합니다.
- 백업 파일은 PVC에 저장되므로 적절한 스토리지 클래스를 사용하세요.
- 백업 주기와 보관 기간을 고려하여 충분한 스토리지를 할당하세요.
- 중요한 데이터의 경우 백업 파일을 외부 스토리지(S3, GCS 등)로 전송하는 추가 스크립트 구현을 고려하세요. 