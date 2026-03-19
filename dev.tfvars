cluster_name   = "my-eks-cluster"

subnet_ids = [
  "subnet-abc123",
  "subnet-def456"
]

cluster_addons = [
  "vpc-cni",
  "coredns",
  "kube-proxy"
]
