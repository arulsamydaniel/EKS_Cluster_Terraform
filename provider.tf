terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  # Adding Backend as S3 for Remote State Storage
  backend "s3" {
    bucket = "daniel-eks-terraform-state-2026"
    key    = "eks/terraform.tfstate"
    region = "ap-south-2"   
  }
}

provider "aws" {
  region = "ap-south-2"
}

locals {
  region = "ap-south-2"
  name   = "daniel_cluster"
  vpc_cidr = "10.123.0.0/16"
  azs      = ["ap-south-2a", "ap-south-2b"]
  public_subnets  = ["10.123.1.0/24", "10.123.2.0/24"]
  private_subnets = ["10.123.3.0/24", "10.123.4.0/24"]
  intra_subnets   = ["10.123.5.0/24", "10.123.6.0/24"]
  tags = {
    Example = local.name
  }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", local.region]
  }
}
