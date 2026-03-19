provider "aws" {
  region = "eu-north-1"
}

############################
# DATA (AUTO SUBNET FETCH)
############################

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

############################
# VARIABLES
############################

variable "cluster_name" {
  default = "my-eks-cluster"
}

variable "cluster_addons" {
  default = [
    "vpc-cni",
    "coredns",
    "kube-proxy"
  ]
}

variable "ng_instance_types" {
  default = ["t3.small"]
}

variable "eks_node_group_policies" {
  default = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  ]
}

############################
# IAM ROLES
############################

resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.cluster_name}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_role_attachment" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role" "nodegroup_role" {
  name = "${var.cluster_name}-nodegroup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "nodegroup_attachment" {
  for_each   = toset(var.eks_node_group_policies)
  role       = aws_iam_role.nodegroup_role.name
  policy_arn = each.value
}

############################
# EKS CLUSTER
############################

resource "aws_eks_cluster" "aws_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids              = data.aws_subnets.default.ids
    endpoint_public_access  = true
    endpoint_private_access = true
    public_access_cidrs     = ["0.0.0.0/0"]
  }

  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_role_attachment]

  timeouts {
    create = "15m"
  }
}

############################
# ADDONS
############################

resource "aws_eks_addon" "eks_addon" {
  for_each     = toset(var.cluster_addons)
  cluster_name = aws_eks_cluster.aws_cluster.name
  addon_name   = each.value

  resolve_conflicts_on_update = "PRESERVE"

  depends_on = [aws_eks_cluster.aws_cluster]

  timeouts {
    create = "2m"
  }
}

############################
# NODE GROUP
############################

resource "aws_eks_node_group" "node_group" {
  cluster_name    = aws_eks_cluster.aws_cluster.name
  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn   = aws_iam_role.nodegroup_role.arn

  subnet_ids = data.aws_subnets.default.ids

  scaling_config {
    desired_size = 3
    max_size     = 3
    min_size     = 1
  }

  instance_types = var.ng_instance_types
  disk_size      = 20
  ami_type       = "AL2023_x86_64_STANDARD"
  capacity_type  = "ON_DEMAND"

  depends_on = [
    aws_eks_cluster.aws_cluster,
    aws_iam_role_policy_attachment.nodegroup_attachment,
    aws_eks_addon.eks_addon
  ]

  timeouts {
    create = "15m"
  }
}
