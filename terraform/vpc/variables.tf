variable "cluster_name" {
  description = "EKS Cluster Name"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block to use for AWS VPC (Recommended netmask: /16)"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (Count: 3, Recommended netmask: /19)"
  type        = list(any)
  default     = ["10.0.0.0/19", "10.0.32.0/19", "10.0.64.0/19"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (Count: 3, Recommended netmask: /19)"
  type        = list(any)
  default     = ["10.0.96.0/19", "10.0.128.0/19", "10.0.160.0/19"]
}
