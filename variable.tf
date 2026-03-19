variable "cluster_name" {
  description = "The name of the EKS cluster."
  type        = string
  
}
variable "subnet_ids" {
  description = "A list of subnet IDs for the EKS cluster."
  type        = list(string)
  
}

variable "cluster_addons" {
  description = "A list of EKS cluster addons to be installed."
  type        = list(string)
  
}
variable "eks_node_group_policies" {
  description = "List of IAM policy ARNs to attach to the node group role"
  type        = list(string)
  default = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  ]
}

variable "ng_instance_types" {
  description = "The instance types for the EKS node group."
  type        = list(string)
  default = [ "t3.small" ]
}
