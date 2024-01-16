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
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
}
