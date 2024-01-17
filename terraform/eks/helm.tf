######################################
## AWS Load Balancer Controller
######################################
resource "helm_release" "aws-load-balancer-controller" {
  name = "aws-load-balancer-controller"

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.5.1"

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }
  set {
    name  = "clusterName"
    value = module.eks.cluster_name
  }
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.load_balancer_controller_irsa_role.iam_role_arn
  }
  set {
    name  = "spec.containers.image"
    value = "public.ecr.aws/eks/aws-load-balancer-controller:v2.4.7"
  }
}

######################################
## Nginx Ingress Controller
######################################
resource "helm_release" "ingress-nginx" {
  name = "ingress-nginx"

  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true

  set {
    name  = "controller.service.type"
    value = "ClusterIP"
  }
  set {
    name  = "controller.config.enable-real-ip"
    value = "true"
  }
  set {
    name  = "controller.config.use-proxy-protocol"
    value = "false"
  }
  set {
    name  = "controller.config.use-forwarded-headers"
    value = "true"
  }
  set {
    name  = "controller.config.http-snippet"
    value = "proxy_cache_path /tmp/nginx/cache levels=1:2 keys_zone=mycache:2m use_temp_path=off max_size=2g inactive=48h;"
  }
  set {
    name  = "controller.config.compute-full-forwarded-for"
    value = "true"
  }
}

######################################
## ALB Ingress
## /ALB Frontend for Nginx-Ingress
## /for handling SSL/Certificates
######################################
resource "helm_release" "alb_ingress" {
  name             = "alb-ingress"
  namespace        = "ingress-nginx"
  create_namespace = true
  chart            = "../charts/alb-ingress"
  set {
    name  = "loadBalancer.name"
    value = "alb-${lower(var.cluster_name)}"
  }
  set {
    name  = "loadBalancer.domain"
    value = var.cluster_subdomain
  }
  set {
    name  = "loadBalancer.certificateArn"
    value = var.aws_acm_certificate_arn
  }
  set {
    name  = "valuesChecksum"
    value = filemd5("../charts/alb-ingress/values.yaml")
  }
}

#####################################
## External DNS
## /manages creation of Route53 records
#####################################
resource "helm_release" "external_dns" {
  name       = "external-dns"
  namespace  = "kube-system"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "external-dns"
  version    = "6.26.0"

  set {
    name  = "aws.roleArn"
    value = module.external_dns_irsa_role.iam_role_arn
  }
  set {
    name = "domainFilters[0]"
    # Use cluster subdomain if we're managing, else use the parent domain
    # domainFilters on AWS will match only the explicit Hosted Zone name
    # (i.e. --domain-filter=dev.nucleize.com won't be able to manage records in nucleize.com Hosted Zone)
    value = var.cluster_subdomain
  }
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.external_dns_irsa_role.iam_role_arn
  }
  set {
    name  = "aws.region"
    value = var.region
  }
  set {
    name  = "ingressClassFilters[0]"
    value = "alb"
  }
  set {
    name  = "interval"
    value = "5m"
  }
  set {
    name  = "triggerLoopOnEvent"
    value = "true"
  }
}
