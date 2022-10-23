// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT
// TERRAMATE: originated from generate_hcl block on /stacks/providers.tm.hcl

provider "aws" {
  region = "us-west-2"
}
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.34"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.7.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.14.0"
    }
  }
}
terraform {
  required_version = "~> 1.2.9"
}
