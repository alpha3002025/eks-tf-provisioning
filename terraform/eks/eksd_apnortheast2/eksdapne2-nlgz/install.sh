#!/bin/bash
set -e

# Configuration
# This script assumes you are in 'eks-tf-provisioning/terraform/eks/eksd_apnortheast2/eksdapne2-wkqo'
CLUSTER_NAME="" # Will be fetched from terraform.tfvars or local state if possible, but better to set explicitly or prompt
REGION="ap-northeast-2"

# Function to extract value from terraform.tfvars
get_tfvar_value() {
    grep "$1" terraform.tfvars | cut -d'=' -f2 | tr -d ' ",' | head -n 1
}

echo "=== 1. Terraform Initialization & Apply ==="
echo "Initializing Terraform..."
terraform init

echo "Applying Terraform..."
# We assume the user has set up their terraform.tfvars and valid credentials
terraform apply -auto-approve

echo "Fetching Cluster Name from outputs..."
# Adjust this based on your actual output variable name in outputs.tf
# In _module/outputs.tf, likely 'cluster_name' or similar if exposed.
# If not exposed directly, we might need to parse it from the tfvars or state.
# Let's try to get it from terraform state if outputs are defined, otherwise fallback to tfvars.
CLUSTER_NAME=$(terraform output -raw cluster_name 2>/dev/null || echo "")

if [ -z "$CLUSTER_NAME" ]; then
    echo "Warning: Could not fetch CLUSTER_NAME from terraform output. Trying to parse from locals/tfvars..."
    # Local fallback logic: Try to construct it as per locals.tf logic implies
    # locals.tf: cluster_name = data.terraform_remote_state.vpc.outputs.eks_cluster_name
    # This implies the cluster name comes from remote state of VPC. 
    # For safety, please enter it manually if detection fails.
    read -p "Enter your EKS Cluster Name manually: " CLUSTER_NAME
fi

echo "Detected Cluster Name: $CLUSTER_NAME"

echo "=== 2. Helm Installation (Karpenter) =="
echo "Checking if Karpenter Helm Chart is installed via Terraform..."
# If _module was updated to include helm_release, this step is done.
# If not, you might need manual installation here, similar to the POC.
# Assuming you followed the guide to add helm_release to _module:
echo "Terraform should have handled Helm release. Verifying..."
aws eks update-kubeconfig --name ${CLUSTER_NAME} --region ${REGION}
kubectl get deployment -n karpenter

echo "=== 3. Kubectl Application (NodePool & EC2NodeClass) ==="
echo "Applying Cost-Optimized Provisioner (NodePool for v1beta1+)..."
echo "NOTE: 이 설정은 실습 비용을 최소화하기 위해 다음과 같이 구성되었습니다:"
echo "      - Spot Instances Only (최대 90% 저렴)"
echo "      - Low Specs (t3, m5 large 이하 위주)"
echo "      - Short TTL (1시간 후 만료, 빠른 축소)"
echo "      - Resource Limits (CPU 20개, Mem 80Gi 제한)"

cat <<EOF | kubectl apply -f -
apiVersion: karpenter.sh/v1beta1
kind: NodePool
metadata:
  name: default
spec:
  template:
    spec:
      requirements:
        # 1. Spot 인스턴스만 사용 (비용 절감 핵심)
        - key: karpenter.sh/capacity-type
          operator: In
          values: ["spot"]
        
        # 2. 저렴한 인스턴스 타입 위주 (t3, m5 등)
        - key: karpenter.k8s.aws/instance-category
          operator: In
          values: ["t3", "m5", "c5"]
        
        # 3. 최신 세대만 사용 (구형 세대는 비싸거나 느릴 수 있음)
        - key: karpenter.k8s.aws/instance-generation
          operator: Gt
          values: ["2"]

      nodeClassRef:
        name: default
      
      # 실습용: 노드가 생성된 지 1시간 지나면 강제로 만료시켜 교체/삭제
      expireAfter: 1h

  # 전체 클러스터 리소스 제한 (실수로 과금되는 것 방지)
  limits:
    cpu: 20
    memory: 80Gi

  # 빠른 축소 정책 (사용 안 하면 10초 뒤 바로 삭제 고려)
  disruption:
    consolidationPolicy: WhenUnderutilized
    consolidateAfter: 10s
---
apiVersion: karpenter.k8s.aws/v1beta1
kind: EC2NodeClass
metadata:
  name: default
spec:
  amiFamily: AL2
  subnetSelectorTerms:
    - tags:
        karpenter.sh/discovery: "${CLUSTER_NAME}"
  securityGroupSelectorTerms:
    - tags:
        karpenter.sh/discovery: "${CLUSTER_NAME}"
  role: "KarpenterNodeRole-${CLUSTER_NAME}" 
  tags:
    Name: karpenter-node-practice
EOF

echo "=== Karpenter installation and configuration complete! ==="
