locals {
  nodegroup_auth_rules = [
    for nodegroup_name in keys(var.managed_node_groups) : {
      rolearn  = module.eks.eks_managed_node_groups[nodegroup_name].iam_role_arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = ["system:bootstrappers", "system:nodes"]
    }
  ]
}
