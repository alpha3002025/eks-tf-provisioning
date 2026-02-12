data "terraform_remote_state" "vpc" {
  backend = "s3"
  ## (1) 로컬
  config = merge(var.remote_state.vpc.eksd_apnortheast2)
  ## (2) 리모트
  # config = merge(var.remote_state.vpc.eksd_apnortheast2, { "assume_role" = { "role_arn" = var.assume_role_arn } })
}


# data "terraform_remote_state" "vpc" {
#   backend = "s3"
#   # assume_role_arn 값이 있을 때만 assume_role 설정을 추가합니다.
#   config = merge(
#     var.remote_state.vpc.eksd_apnortheast2,
#     var.assume_role_arn != "" ? { "assume_role" = { "role_arn" = var.assume_role_arn } } : {}
#   )
# }
