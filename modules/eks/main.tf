# setup aws terraform provider version to be used
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.6.2"
    }
  }
}

module "eks" {

  source  = "terraform-aws-modules/eks/aws"
  version                         = "19.15.3"

  cluster_name                    = var.eks_cluster_name
  cluster_version                 = var.k8s_version
  vpc_id                          = var.vpc_id
  control_plane_subnet_ids        = var.control_plane_subnet_ids
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  # create an OpenID Connect Provider for EKS to enable IRSA
  enable_irsa                     = true

  cluster_addons = {
    # extensible DNS server that can serve as the Kubernetes cluster DNS
    coredns = {
      preserve    = true
      most_recent = true
    }

    # maintains network rules on each Amazon EC2 node. It enables network communication to your Pods
    kube-proxy = {
      most_recent = true
    }

    # a Kubernetes container network interface (CNI) plugin that provides native VPC networking for your cluster
    vpc-cni = {
      most_recent = true
    }
  }

  subnet_ids                      = var.eks_node_groups_subnet_ids
  eks_managed_node_groups         = var.workers_config
}
