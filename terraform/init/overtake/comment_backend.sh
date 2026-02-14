#!/bin/bash

# 스크립트 파일이 있는 디렉토리를 기준으로 경로 설정
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET_FILE="$SCRIPT_DIR/backend.tf"

# 파일 존재 확인
if [ -f "$TARGET_FILE" ]; then
    echo "Processing: $TARGET_FILE"
    
    # macOS용 sed 구문: 전체 라인 주석 처리
    # 범위를 지정하지 않으면 모든 줄에 적용됩니다. (또는 '1,$s/^/#/'로 명시 가능)
    sed -i '' 's/^/#/' "$TARGET_FILE"
    
    echo "Successfully commented out ALL lines in backend.tf"
else
    echo "Error: backend.tf not found in $SCRIPT_DIR"
    exit 1
fi
