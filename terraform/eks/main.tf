

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name                 = "gitops-vpc"
  cidr                 = var.vpc_cidr
  azs                  = ["us-east-1a", "us-east-1b"]
  public_subnets       = var.public_subnets
  private_subnets      = var.private_subnets
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }

  tags = {
    Project                                     = "gitops"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.27"
  subnet_ids      = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

  cluster_endpoint_public_access = true
  enable_irsa                    = true

  eks_managed_node_groups = {
    default = {
      name           = "gitops-nodes"
      instance_types = [var.node_instance_type]
      desired_size   = var.desired_capacity
      max_size       = var.max_capacity
      min_size       = var.min_capacity
    }
  }

  manage_aws_auth_configmap = true

  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::980921714633:user/eks-admin"
      username = "eks-admin"
      groups   = ["system:masters"]
    }
  ]

  tags = {
    Name        = "gitops-node"
    Environment = "Dev"
    Project     = "GitOps-ArgoCD"
  }
}

