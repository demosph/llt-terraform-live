terraform {
  backend "s3" {
    bucket         = "llt-tfstate-bucket"
    key            = "infra/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
