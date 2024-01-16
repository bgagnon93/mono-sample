module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.3"

  cluster_name    = var.cluster_name
  cluster_version = var.eks_version

  vpc_id = var.vpc_id
  subnet_ids = concat(
    var.private_subnets,
    var.public_subnets
  )

  node_security_group_tags = {
    "karpenter.sh/discovery" = var.cluster_name
  }

  cluster_endpoint_public_access = true

  tags = var.tags
  cluster_addons = {
    coredns = {
      preserve    = true
      most_recent = true

      timeouts = {
        create = "25m"
        delete = "10m"
      }
    }
    aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = module.ebs_csi_irsa_role.iam_role_arn
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent              = true
      service_account_role_arn = module.vpc_cni_ipv4_irsa_role.iam_role_arn
    }
  }


  kms_key_enable_default_policy = true
  kms_key_administrators = concat(
    [data.aws_caller_identity.current.arn],
    var.cluster_admins
  )
  kms_key_users = []

  # aws-auth configmap
  manage_aws_auth_configmap = true


  aws_auth_roles = concat(
    local.nodegroup_auth_rules,
    [
      {
        rolearn  = module.karpenter.role_arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups = [
          "system:nodes",
          "system:bootstrappers"
        ]
      }
    ]
  )

  aws_auth_users = [
    {
      userarn  = data.aws_caller_identity.current.arn
      username = "Terraform-User"
      groups = [
        "system:masters"
      ]
    },
    #### This part will need some refactoring. Need a good way to define admins in tfvars and iterate through
    {
      userarn  = "arn:aws:iam::${var.account_id}:user/brian.gagnon"
      username = "brian.gagnon"
      groups = [
        "system:masters"
      ]
    }
  ]

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
  }

  eks_managed_node_groups = var.managed_node_groups

}

module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "19.15.3"

  cluster_name = module.eks.cluster_name

  irsa_use_name_prefix            = false
  irsa_oidc_provider_arn          = module.eks.oidc_provider_arn
  irsa_namespace_service_accounts = ["karpenter:karpenter"]

  tags = var.tags
}

module "ebs_csi_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name             = "eks-ebs-csi-driver-role-${var.cluster_name}"
  attach_ebs_csi_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = var.tags
}

module "vpc_cni_ipv4_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name             = "eks-vpc-cni-ipv4-${var.cluster_name}"
  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }

  tags = var.tags
}

module "load_balancer_controller_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name                              = "load-balancer-controller-${var.cluster_name}"
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }

  tags = var.tags
}

module "external_dns_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name                     = "external-dns-${var.cluster_name}"
  attach_external_dns_policy    = true
  external_dns_hosted_zone_arns = ["arn:aws:route53:::hostedzone/${var.eks_cluster_zone_id}"]

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:external-dns"]
    }
  }

  tags = var.tags
}
