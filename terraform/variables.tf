variable "account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"

}

variable "cluster_name" {
  description = "EKS Cluster Name"
  type        = string
}

variable "parent_domain" {
  description = "Parent domain of desired subdomain - used for retrieving Hosted Zone ID"
  type        = string
}

variable "cluster_subdomain" {
  description = "Route53 subdomain for DNS entries"
  type        = string
  default     = "eks.gagnonagon.com"
}

variable "managed_node_groups" {
  type = map(object({
    name           = string
    instance_types = list(string)
    desired_size   = number
    min_size       = number
    max_size       = number
    capacity_type  = optional(string)
    taints         = optional(map(map(any)), {})
    labels         = optional(map(string), {})
  }))
  default = {
    one = {
      name           = "eks-ng1"
      instance_types = ["t3.medium"]
      min_size       = 2
      max_size       = 4
      desired_size   = 3
      capacity_type  = "ON_DEMAND"
      tags = {
        owner     = "cloudops"
        contact   = "bgagnon93@gmail.com"
        terraform = "true"
      }
      labels = {
        terraform_managed = true
        lifecycle         = "ondemand"
      }
    }
  }
}

variable "cluster_admins" {
  description = "User ARNs of cluster administrators"
  type        = list(string)
  default     = []
}

variable "contact" {
  description = "Contact information for cluster owner"
  type        = string
  default     = "bgagnon93@gmail.com"
}

variable "client" {
  description = "Identifies the client owner of the cluster"
  type        = string
  default     = "internal"
}

variable "cost_center" {
  description = "Cost Center defined for the user:CostCenter tag (for AWS billing)"
  type        = string
  default     = "core"
}

variable "environment" {
  description = "Environment identifier per SDLC (i.e. dev,staging,prod,shared-services)"
  type        = string
  default     = "test"
}
