resource "aws_iam_role" "nodegroup_role" {
    name = "${var.cluster_name}-nodegroup-role"
     assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
  
}

resource "aws_iam_role_policy_attachment" "nodegroup_attachment" {
    for_each = toset(var.eks_node_group_policies)
    role       = aws_iam_role.nodegroup_role.name
    policy_arn = each.value
  
}
