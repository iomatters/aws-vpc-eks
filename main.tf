provider "aws" {
  region = var.region
}

module "vpc" {
  source = "./modules/vpc"

  vpc_name  = var.vpc_name
  vpc_cidr  = var.vpc_cidr
}

module "eks" {
  source = "./modules/eks"

  eks_cluster_name           = var.cluster_name
  k8s_version                = var.k8s_version
  vpc_id                     = module.vpc.vpc_id
  eks_node_groups_subnet_ids = module.vpc.private_subnets
  control_plane_subnet_ids   = module.vpc.private_subnets
}
