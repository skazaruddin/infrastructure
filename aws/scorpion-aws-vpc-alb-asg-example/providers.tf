
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.18.0"
    }
  }

  backend "s3" {
    bucket         = "scorpion-terraform-tfstate"
    key            = "state/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "scorpion-terraform-statelock"
  }
}
