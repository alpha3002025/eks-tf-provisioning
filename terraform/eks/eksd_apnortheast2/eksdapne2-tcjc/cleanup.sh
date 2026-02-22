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


# 5. (혹시 실패하면) 잔여 보안 그룹 강제 삭제 후 재시도
if [ $? -ne 0 ]; then
  echo "Terraform destroy failed. Checking for leftover Security Groups..."
  # VPC ID 조회
  VPC_ID=$(terraform output -raw vpc_id)
  # EKS SG 찾아서 삭제
  aws ec2 describe-security-groups --filters Name=vpc-id,Values=$VPC_ID Name=group-name,Values=eks-cluster-sg* ... | xargs aws ec2 delete-security-group ...
  
  # 다시 Destroy
  terraform destroy -auto-approve
fi