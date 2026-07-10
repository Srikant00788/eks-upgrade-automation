terraform {

  required_version = ">= 1.9.0"

  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.90"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.36"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.16"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }

  }

}
