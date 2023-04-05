provider "aws" {
  region  = "ap-southeast-1"
  access_key=var.aws_access_key
  secret_key=var.aws_secret_key
}

terraform {
  backend "s3" {
    bucket = "munna-tfstate"
    key    = "terraform.tfstate"
    region = "ap-southeast-1"
  }
}