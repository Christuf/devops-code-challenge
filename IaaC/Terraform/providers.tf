provider "aws" {
  region = "us-east-1"
  profile = "christuf"
}

terraform {
  backend "s3" {
    profile = "christuf"
    bucket = "tv-state-christuf"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}
