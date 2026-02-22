## (1)
# assume_role_arn = "arn:aws:iam::066346343248:role/assume-id-admin"
# Basic Information
account_alias = "id"
## (2)
product = "eks"

# Cluster information
cluster_version = "1.34"            ## (3) 1.30 ➝ 1.34
release_version = "1.34.0-20251215" ## (4) ➝ 1.34.0-20251215

# Service CIDR
service_ipv4_cidr = "172.20.0.0/16"

# Addon information
# https://docs.aws.amazon.com/eks/latest/userguide/managing-coredns.html
coredns_version = "v1.11.4-eksbuild.2" ## (5) ➝ v1.11.4-eksbuild.2

# https://docs.aws.amazon.com/eks/latest/userguide/managing-kube-proxy.html
kube_proxy_version = "v1.30.0-eksbuild.2" ## (6) ➝ v1.30.0-eksbuild.2

# https://docs.aws.amazon.com/eks/latest/userguide/managing-vpc-cni.html
vpc_cni_version = "v1.19.2-eksbuild.1" ## (7) ➝ v1.19.2-eksbuild.1

## (8) 사용 x
## terraform/_module/addons.tf 에서 ebs_csi_driver 을 검색해보면 deploy_ebs_csi_driver 를 확인할 수 있다.
# https://github.com/kubernetes-sigs/aws-ebs-csi-driver
deploy_ebs_csi_driver  = false
ebs_csi_driver_version = "v1.34.0-eksbuild.1"

## (9) 사용 x
## terraform/_module/addons.tf 에서 ebs_csi_driver 을 검색해보면 deploy_pod_identity_agent 를 확인할 수 있다.
# https://github.com/aws/eks-pod-identity-agent
deploy_pod_identity_agent  = false
pod_identity_agent_version = "v1.3.2-eksbuild.2"

# Fargate Information
fargate_enabled      = false
fargate_profile_name = ""

# Node Group configuration ## (10) 추가
enabled_node_disk_gp3 = true ## (10) 추가

# Node Group configuration
node_group_configurations = [
  {
    name                = "ondemand_default" ## (11) ➝ ondemand_1_30_4-20241024 ➝ ondemand_default
    spot_enabled        = false
    release_version     = "1.34.0-20251215" ## (12) ➝ 1.34.0-20251215
    disk_size           = 20
    ami_type            = "AL2023_x86_64_STANDARD"
    node_instance_types = ["t3.large"]
    node_min_size       = 0
    node_desired_size   = 1
    node_max_size       = 2
    labels = {
      "cpu_chip" = "intel"
    }
  },
  {
    name                = "spot_default" ## (13) spot_1_30_4-20241024 ➝ spot_default
    spot_enabled        = true
    disk_size           = 20
    release_version     = "1.34.0-20251215" ## (14) 1.30.4-20241024 ➝ 1.34.0-20251215
    ami_type            = "AL2023_x86_64_STANDARD"
    node_instance_types = ["t3.large"]
    node_min_size       = 0
    node_desired_size   = 1
    node_max_size       = 5
    labels = {
      "cpu_chip" = "intel"
    }
  },
]

additional_security_group_ingress = [
  {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["10.20.0.0/16"] ## (15) 10.10.0.0/16 ➝ 10.20.0.0/16
  }
]

# Specified KMS ARNs accessed by ExternalSecrets
external_secrets_access_kms_arns = [
  ## (16) 
  ## 주석처리
  # "arn:aws:kms:ap-northeast-2:066346343248:key/79e6d15d-a3b1-431a-a6a2-ae9c63c25ddb"
  ## * 로 지정
  "*"
]

# Specified SSM ARNs accessed by ExternalSecrets
external_secrets_access_ssm_arns = [
  "*"
]

# Specified SecretsManager ARNs accessed by ExternalSecrets
external_secrets_access_secretsmanager_arns = [
  "*"
]
