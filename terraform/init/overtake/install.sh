#!/bin/bash

# 스크립트 실행 중 에러 발생 시 처리
# source로 실행 중일 때는 exit 대신 return을 사용하여 셸 종료 방지
# 그러나 set -e는 source 된 스크립트에서도 에러 발생 시 부모 셸을 종료시킬 수 있는 위험이 있음
# 따라서 set -e 대신 각 명령의 성공 여부를 직접 확인하는 방식으로 변경

# 에러 처리 함수
handle_error() {
    echo "Error occurred in step: $1"
    # 스크립트가 source로 실행되었는지 확인
    if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
        return 1 2>/dev/null || exit 1
    else
        exit 1
    fi
}

# 스크립트 파일이 위치한 디렉토리로 이동 (source로 실행 시 $0이 다를 수 있어 주의 필요하나, 일반적인 실행 호환성 유지)
if [ -n "$BASH_SOURCE" ]; then
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
else
    SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
fi
cd "$SCRIPT_DIR" || handle_error "Changing directory"

# 실행 권한 부여
chmod +x ./comment_backend.sh || handle_error "chmod comment_backend.sh"
chmod +x ./uncomment_backend.sh || handle_error "chmod uncomment_backend.sh"

echo "----------------------------------------------------------------"
echo "Step 1: Commenting out backend (Local State Mode)"
echo "----------------------------------------------------------------"
# backend.tf 주석 처리
./comment_backend.sh || handle_error "Step 1: Commenting out backend"

echo "----------------------------------------------------------------"
echo "Step 2: Terraform Init (Local)"
echo "----------------------------------------------------------------"
# -reconfigure: 기존 백엔드 설정 무시하고 재설정
terraform init -reconfigure || handle_error "Step 2: Terraform Init (Local)"

echo "----------------------------------------------------------------"
echo "Step 3: Terraform Plan (Local)"
echo "----------------------------------------------------------------"
terraform plan --parallelism 3 || handle_error "Step 3: Terraform Plan (Local)"

echo "----------------------------------------------------------------"
echo "Step 4: Terraform Apply (Local)"
echo "----------------------------------------------------------------"
# -auto-approve: 'yes' 입력 자동화
terraform apply -auto-approve || handle_error "Step 4: Terraform Apply (Local)"

echo "----------------------------------------------------------------"
echo "Step 5: Uncommenting backend (S3 Backend Mode)"
echo "----------------------------------------------------------------"
# backend.tf 주석 해제
./uncomment_backend.sh || handle_error "Step 5: Uncommenting backend"

echo "----------------------------------------------------------------"
echo "Step 6: Terraform Init (Migrate to S3)"
echo "----------------------------------------------------------------"
# -force-copy: 상태 마이그레이션 시 'yes' 입력 자동화
terraform init -force-copy || handle_error "Step 6: Terraform Init (Migrate to S3)"

echo "----------------------------------------------------------------"
echo "Step 7: Terraform Plan (S3)"
echo "----------------------------------------------------------------"
terraform plan --parallelism 3 || handle_error "Step 7: Terraform Plan (S3)"

echo "----------------------------------------------------------------"
echo "Step 8: Terraform Apply (S3)"
echo "----------------------------------------------------------------"
# -auto-approve: 'yes' 입력 자동화
terraform apply -auto-approve || handle_error "Step 8: Terraform Apply (S3)"

echo "----------------------------------------------------------------"
echo "All steps completed successfully!"
echo "----------------------------------------------------------------"
