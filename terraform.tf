terraform {
  backend "s3" {
    bucket = "mn-bucket-terrafform-state"
    key    = "mn-rnd/terraform.tfstate"
    region = "ap-southeast-1"
  }
}