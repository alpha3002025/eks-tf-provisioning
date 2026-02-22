provider "aws" {
  region = var.aws_region

  ### (1) --- start
  assume_role {
    role_arn     = var.assume_role_arn
    session_name = var.atlantis_user
  }
  ### (1) --- end  (1) : 이 부분은 삭제시 에러날 경우 주석처리

  ignore_tags {
    key_prefixes = ["kubernetes.io/", "karpenter.sh/"]
  }
}

provider "random" {}
