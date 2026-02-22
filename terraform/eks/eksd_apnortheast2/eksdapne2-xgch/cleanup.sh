#!/bin/bash
# destroy.sh

# 1. Karpenter NodePool 정리 (노드 삭제 유발)
echo "Deleting Karpenter NodePools..."
kubectl delete nodepool --all
kubectl delete ec2nodeclass --all

# 2. 노드가 다 사라질 때까지 대기 (예: 2분)
echo "Waiting for Karpenter nodes to terminate..."
sleep 120 
# (더 정교하게 하려면 kubectl get nodes -l karpenter.sh/nodepool 로 개수 체크)

# 3. 그 외 로드밸런서 등 잔여 리소스 체크 (선택)

# 4. Terraform Destroy
echo "Running Terraform Destroy..."
terraform destroy -auto-approve