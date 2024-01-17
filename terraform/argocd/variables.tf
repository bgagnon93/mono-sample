variable "cluster_name" {
  description = "EKS Cluster Name"
  type        = string
}

variable "cluster_subdomain" {
  description = "Route53 subdomain for DNS entries"
  type        = string
}

variable "whitelist_cidrs" {
  description = "Whitelisted CIDR blocks for ArgoCD Ingress"
  type        = list(string)
  default     = []
}

#=============================
## ArgoCD Params
#=============================
# These might be able to go away if we use argocd-operator or bootstrap it another way
variable "argocd_ingress_class" {
  description = "Ingress Class to use for ArgoCD"
  type        = string
  default     = "nginx"
}

variable "argocd_github_token" {
  description = "Github Access token for Armosforge (for ArgoCD)"
  type        = string
  default     = "undefined"
  sensitive   = true
}

variable "values_file" {
  description = "Path to values file for ArgoCD"
  type        = string
  default     = "helm/argocd/values.yaml"
}
