resource "aws_s3_bucket" "tfstate" {
  bucket        = "overtake-eks-apnortheast2-tfstate" ## (1)
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.tfstate.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name         = "overtake-eks-terraform-lock" ## (2)
  hash_key     = "LockID"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }
}
