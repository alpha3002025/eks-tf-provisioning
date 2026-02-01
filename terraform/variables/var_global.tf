variable "assume_role_arn" {
  description = "The role to assume when accessing the AWS API."
  default     = ""
}

variable "aws_region" {
  description = "The AWS region to deploy to."
  default     = "ap-northeast-2"
}

# Atlantis user
variable "atlantis_user" {
  description = "The username that will be triggering atlantis commands. This will be used to name the session when assuming a role. More information - https://github.com/runatlantis/atlantis#assume-role-session-names"
  default     = "atlantis_user"
}

# Account IDs
# Add all account ID to here 
variable "account_id" {
  default = {
    id = "533267446521"
  }
}

# Remote State that will be used when creating other resources
# You can add any resource here, if you want to refer from others
variable "remote_state" {
  default = {
    ## 추가
    vpc = {
      eksd_apnortheast2 = {
        bucket = "overtake-eks-apnortheast2-tfstate"
        key    = "provisioning/terraform/vpc/eksd_apnortheast2/terraform.tfstate"
        region = "ap-northeast-2"
      }
      prjd_apnortheast2 = {
        bucket = "overtake-eks-apnortheast2-tfstate"
        key    = "provisioning/terraform/vpc/prjd_apnortheast2/terraform.tfstate"
        region = "ap-northeast-2"
      }
    }
    ## 추가
    iam = {
      overtake = { ## 잠깐 햇갈려서 (1) 로 지정해둠
        bucket = "overtake-eks-apnortheast2-tfstate"
        ## (1) bucket = "overtake-eks-iam-apnortheast2-tfstate"
        key    = "provisioning/terraform/iam/overtake/terraform.tfstate"
        region = "ap-northeast-2"
      }
    }
    ## 추가
    kms = {
      overtake = {
        apne2 = {
          bucket = "overtake-eks-apnortheast2-tfstate"
          key    = "provisioning/terraform/kms/overtake/ap-northeast-2/terraform.tfstate"
          region = "ap-northeast-2"
        }
      }
    }
    ## 추가
    secretsmanager = {
      overtake = {
        apne2 = {
          bucket = "overtake-eks-apnortheast2-tfstate"
          key    = "provisioning/terraform/secretsmanager/overtake/ap-northeast-2/terraform.tfstate"
          region = "ap-northeast-2"
        }
      }
    }
  }
}
