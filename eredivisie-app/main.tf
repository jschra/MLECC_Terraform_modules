# Set backend
terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket-mlecc"
    key            = "test/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = "eu-west-1"
}