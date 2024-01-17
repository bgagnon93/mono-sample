module "vpc" {
  source       = "./vpc"
  cluster_name = var.cluster_name
}

module "dns" {
  source            = "./dns"
  cluster_name      = var.cluster_name
  parent_domain     = var.parent_domain
  cluster_subdomain = var.cluster_subdomain
  tags              = local.tags

  depends_on = [module.vpc]
}

module "eks" {
  source = "./eks"

  account_id          = var.account_id
  cluster_name        = var.cluster_name
  cluster_subdomain   = var.cluster_subdomain
  cluster_admins      = var.cluster_admins
  managed_node_groups = var.managed_node_groups

  vpc_id                  = module.vpc.vpc_id
  public_subnets          = module.vpc.public_subnets
  private_subnets         = module.vpc.private_subnets
  eks_cluster_zone_id     = module.dns.eks_cluster_zone_id
  aws_acm_certificate_arn = module.dns.aws_acm_certificate_arn

  tags = local.tags
}

module "argocd" {
  source = "./argocd"

  cluster_name      = var.cluster_name
  cluster_subdomain = var.cluster_subdomain

  depends_on = [module.eks]
}
