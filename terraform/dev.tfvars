# EKS Internal Dev Cluster

### ADMINISTRATIVE INFO ###
account_id  = "983510677257"
region      = "us-east-1"
environment = "dev"
cost_center = "core"
contact     = "bgagnon93@gmail.com"
client      = "internal"

### CLUSTER INFO ###
cluster_name      = "bgagnon-eks-dev-us-east-1"
cluster_subdomain = "dev.gagnonagon.com"
parent_domain     = "gagnonagon.com"
# eks_version       = "1.28"
# vpc_cidr            = "10.1.0.0/16"
# acm_certificate_arn = "" # Maybe we automate deployment of Certificates too!
# private_subnet_cidrs = [
#   "10.1.0.0/19",
#   "10.1.32.0/19",
#   "10.1.64.0/19"
# ]
# public_subnet_cidrs = [
#   "10.1.96.0/19",
#   "10.1.128.0/19",
#   "10.1.160.0/19"
# ]
managed_node_groups = {
  "base-nodegroup" = {
    name           = "eks-base-nodegroup"
    instance_types = ["t3.medium"]
    desired_size   = 3
    min_size       = 2
    max_size       = 5
    tags = {
      client            = "internal"
      contact           = "bgagnon93@gmail.com"
      environment       = "dev"
      "user:CostCenter" = "core"
    }
    labels = {
      terraform_managed = true
      lifecycle         = "ondemand"
    }
  }
}
