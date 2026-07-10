terraform {

  backend "s3" {

    bucket = "srikant00788-eks-upgrade-tfstate-2026"

    key = "prod/terraform.tfstate"

    region = "us-east-1"

    dynamodb_table = "eks-upgrade-lock"

    encrypt = true

  }

}
