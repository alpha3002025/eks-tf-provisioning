terraform {
  required_version = ">= 1.0.0"

  backend "s3" {
    bucket         = "overtake-eks-apnortheast2-tfstate"
    key            = "provisioning/terraform/eks/eksd_apnortheast2/eksdapne2-bwwn/terraform.tfstate"
    region         = "ap-northeast-2"
    encrypt        = true
    dynamodb_table = "overtake-eks-terraform-lock"
  }
}
