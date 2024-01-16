# bgagnon account backend:
terraform {
  backend "s3" {
    bucket  = "983510677257-misc"
    key     = "terraform/bgagnon/terraform.tfstate"
    region  = "us-east-1"
    profile = "admin"
  }
}
