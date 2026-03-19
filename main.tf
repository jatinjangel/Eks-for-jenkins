resource "aws_eks_cluster" "aws_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = var.subnet_ids

     endpoint_public_access  = true   
    endpoint_private_access = true 
    public_access_cidrs     = ["0.0.0.0/0"] 
    
    
  }
  
  access_config {
    authentication_mode = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }

  depends_on = [aws_iam_role.eks_cluster_role] 

  timeouts {
 create = "15m"
  }
  
}

resource "aws_eks_addon" "eks_addon" {

  cluster_name = aws_eks_cluster.aws_cluster.name
  for_each = toset(var.cluster_addons)
  addon_name = each.value
  resolve_conflicts_on_update = "PRESERVE"
  timeouts {
    create = "10m"
  }

  depends_on = [aws_eks_node_group.node_group]
  
}

resource "aws_eks_node_group" "node_group" {
  cluster_name    = aws_eks_cluster.aws_cluster.name
  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn   = aws_iam_role.nodegroup_role.arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = 3
    max_size     = 3
    min_size     = 1
  }
  instance_types = var.ng_instance_types
  disk_size = 20
  ami_type = "AL2023_x86_64_STANDARD"
  capacity_type = "ON_DEMAND"

  depends_on = [aws_eks_cluster.aws_cluster, aws_iam_role.nodegroup_role, aws_eks_addon.eks_addon, aws_iam_role_policy_attachment.nodegroup_attachment]

  timeouts {

    create = "15m"
    
  }
 

  
}  
