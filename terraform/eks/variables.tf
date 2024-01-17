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

variable "cluster_subdomain" {
  description = "Route53 subdomain for DNS entries"
  type        = string
}

variable "eks_version" {
  description = "EKS Cluster Version"
  type        = string
  default     = "1.28"
}

variable "cluster_admins" {
  description = "User ARNs of cluster administrators"
  type        = list(string)
  default     = []
}

variable "vpc_id" {
  description = "VPC ID"
}

variable "public_subnets" {
  description = "Public subnets"
}

variable "private_subnets" {
  description = "Private subnets"
}

variable "eks_cluster_zone_id" {
  description = "Route53 Zone ID for EKS Cluster"
}

variable "aws_acm_certificate_arn" {
  description = "AWS ACM Certificate ARN"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
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
}
