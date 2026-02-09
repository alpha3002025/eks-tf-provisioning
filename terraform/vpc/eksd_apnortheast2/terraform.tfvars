product            = "eks" ## (1)
aws_region         = "ap-northeast-2"
aws_short_region   = "apne2"
cidr_numeral       = "20" ## (2)
availability_zones = ["ap-northeast-2a", "ap-northeast-2c"]
billing_tag        = "eks" ## (3)
env_suffix         = "d"
shard_id           = "eksdapne2" ## (4)

peering_requests = [
]

db_peering_requests = [
]

vpc_peering_list = [

]
