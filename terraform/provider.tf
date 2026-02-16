terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "kubernetes" {
  host                   = aws_eks_cluster.reactf.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.reactf.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.reactf.token
}
