terraform {
  backend "s3" {
    bucket         = "llt-tfstate-bucket"
    key            = "apps/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

data "terraform_remote_state" "infra" {
  backend = "s3"
  config = {
    bucket         = "llt-tfstate-bucket"
    key            = "infra/terraform.tfstate"
    dynamodb_table = "terraform-locks"
    region = var.region
  }
}
