## karpenter controller
resource "aws_iam_role" "karpenter_controller" {
  name = "eks-${var.cluster_name}-karpenter-controller"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "${local.openid_connect_provider_id}"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "${local.openid_connect_provider_url}:aud" : "sts.amazonaws.com",
            "${local.openid_connect_provider_url}:sub" : "system:serviceaccount:karpenter:karpenter"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "karpenter_controller" {
  name = "eks-${var.cluster_name}-karpenter-controller-policy"
  policy = jsonencode({
    "Statement" : [
      {
        "Action" : [
          "ssm:GetParameter",
          "iam:PassRole",
          "ec2:DescribeImages",
          "ec2:RunInstances",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeLaunchTemplates",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeInstanceTypeOfferings",
          "ec2:DescribeAvailabilityZones",
          "ec2:DeleteLaunchTemplate",
          "ec2:CreateTags",
          "ec2:CreateLaunchTemplate",
          "ec2:CreateFleet",
          "ec2:DescribeSpotPriceHistory",
          "pricing:GetProducts",               ## (1) (!!!업데이트) 강의 내용과 다르게 추가해줘야 했던 부분
          "iam:CreateInstanceProfile",         ## (1) (!!!업데이트) 강의 내용과 다르게 추가해줘야 했던 부분
          "iam:TagInstanceProfile",            ## (1) (!!!업데이트) 강의 내용과 다르게 추가해줘야 했던 부분
          "iam:AddRoleToInstanceProfile",      ## (1) (!!!업데이트) 강의 내용과 다르게 추가해줘야 했던 부분
          "iam:RemoveRoleFromInstanceProfile", ## (1) (!!!업데이트) 강의 내용과 다르게 추가해줘야 했던 부분
          "iam:DeleteInstanceProfile",         ## (1) (!!!업데이트) 강의 내용과 다르게 추가해줘야 했던 부분
          "iam:GetInstanceProfile"             ## (1) (!!!업데이트) 강의 내용과 다르게 추가해줘야 했던 부분
        ],
        "Effect" : "Allow",
        "Resource" : "*",
        "Sid" : "Karpenter"
      },
      {
        "Action" : "ec2:TerminateInstances",
        "Condition" : {
          "StringLike" : {
            "ec2:ResourceTag/Name" : "*karpenter*"
          }
        },
        "Effect" : "Allow",
        "Resource" : "*",
        "Sid" : "ConditionalEC2Termination"
      },
      ## (1) 위의 'ec2:TerminateInstances' 의 내용을 복사 후 다음과 같이 수정
      {
        "Action" : "eks:DescribeCluster", ## (1) "eks:DescribeCluster" 로 변경
        "Effect" : "Allow",
        "Resource" : "${aws_eks_cluster.eks_cluster.arn}", ## (1) "${aws_eks_cluster.eks_cluster.arn}" 으로 변경 ((2) 의 내용을 복사함)
        "Sid" : "DescribeCluster"                          ## (1) "DescribeCluster" 로 변경
      }
    ],
    "Version" : "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "karpenter_controller" {
  policy_arn = aws_iam_policy.karpenter_controller.arn
  role       = aws_iam_role.karpenter_controller.name
}


## tags for security group
data "aws_security_group" "cluster_sg" {
  tags = tomap({
    "aws:eks:cluster-name" = "${var.cluster_name}"
  })
  depends_on = [aws_eks_cluster.eks_cluster] ## (2) 이 부분을 복사
}

resource "aws_ec2_tag" "karpenter_cluster_sg_tag" {
  resource_id = data.aws_security_group.cluster_sg.id
  key         = "karpenter.sh/discovery"
  value       = var.cluster_name
}

resource "aws_ec2_tag" "karpenter_private_subnet_tag" {
  for_each    = toset(var.private_subnets)
  resource_id = each.value
  key         = "karpenter.sh/discovery"
  value       = var.cluster_name
}

## (1)
variable "enable_karpenter" {
  description = "Controls whether to deploy Karpenter resources"
  type        = bool
  default     = true
}

resource "helm_release" "karpenter" {
  ## (2)
  count = var.enable_karpenter ? 1 : 0 # <--- Karpenter 설치 여부 제어

  namespace        = "karpenter"
  create_namespace = true

  name       = "karpenter"
  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"
  version    = "v0.32.1" # 호환되는 최신 버전 사용 (v1beta1 API 지원 버전)

  # 필수 설정 값 주입
  set {
    name  = "settings.clusterName"
    value = var.cluster_name
  }

  set {
    name  = "settings.clusterEndpoint"
    value = aws_eks_cluster.eks_cluster.endpoint
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.karpenter_controller.arn
  }

  # (선택) Spot Interruption 처리를 위한 Queue 설정
  # set {
  #   name  = "settings.interruptionQueueName"
  #   value = var.cluster_name
  # }
}

