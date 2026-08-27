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
data "aws_eks_cluster" "default" {
  name = local.name
}

data "aws_eks_cluster_auth" "default" {
  name = local.name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.default.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.default.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.default.token
}
