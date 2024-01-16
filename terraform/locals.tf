locals {
  # Default set of tags to include on most resources
  tags = {
    terraform         = "true"
    cluster           = var.cluster_name
    contact           = var.contact
    "user:CostCenter" = var.cost_center
    environment       = var.environment
  }
}
