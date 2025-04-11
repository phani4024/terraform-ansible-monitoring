terraform {
  backend "s3" {
    bucket = "backup.terraform.phani"
    key    = "prod/terraform.tfstate"
    region = "us-east-1"
  }
}
