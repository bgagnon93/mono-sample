######################################
## ArgoCD: Server, Apps, Rollouts, Workflows
## /deployment management
######################################
resource "helm_release" "argocd" {
  name              = "argocd"
  namespace         = "argocd"
  create_namespace  = true
  dependency_update = true
  chart             = "../charts/argocd"
  # repository        = "https://argoproj.github.io/argo-helm"
  # chart             = "argo-cd"

  # If values file specified by the var.values_file input variable exists then apply the values from this file
  # else apply the default values from the chart
  values = [fileexists("${path.root}/${var.values_file}") == true ? file("${path.root}/${var.values_file}") : ""]

  set {
    name  = "argo-cd.configs.credentialTemplates.https-creds.password"
    value = var.argocd_github_token
  }
  set {
    name  = "argo-cd.server.ingress.hosts[0]"
    value = "argocd.${var.cluster_subdomain}"
  }
  set {
    name  = "argo-cd.server.ingress.ingressClassName"
    value = var.argocd_ingress_class
  }
  set {
    name  = "argo-cd.server.ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/whitelist-source-range"
    value = join("\\,", var.whitelist_cidrs)
  }
  # set {
  #   name  = "valuesChecksum"
  #   value = filemd5("helm/argocd/values.yaml")
  # }
}

resource "helm_release" "argocd_rollouts" {
  name             = "argo-rollouts"
  namespace        = "argocd"
  create_namespace = true
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-rollouts"
  version          = "2.28.0"
}

# resource "helm_release" "argocd_apps" {
#   name             = "argocd-apps"
#   namespace        = "argocd"
#   create_namespace = true
#   repository       = "https://argoproj.github.io/argo-helm"
#   chart            = "argocd-apps"

#   values = [""]
#   # set {
#   #   name  = "valuesChecksum"
#   #   value = filemd5("helm/argocd-apps/values.yaml")
#   # }
#   set {
#     name  = "applications[0].source.path"
#     value = "helm/${var.cluster_name}"
#   }
#   depends_on = [
#     helm_release.argocd
#   ]
# }
