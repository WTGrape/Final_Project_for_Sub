resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "helm_release" "node_exporter" {
  name        = "node-exporter"
  namespace   = kubernetes_namespace.monitoring.metadata[0].name
  repository  = "https://charts.bitnami.com/bitnami"
  chart       = "node-exporter"
  version     = "4.1.0"

  set {
    name  = "rbac.pspEnabled"
    value = "false"
  }
  set {
    name  = "serviceAccount.name"
    value = local.node_exporter_service_account_name
  }
  set {
    name  = "service.type"
    value = "NodePort"
  }

  set {
    name  = "ingress.enabled"
    value = "true"
  }

  set {
    name  = "ingress.annotations.kubernetes\\.io/ingress\\.class"
    value = "alb"
  }
  set {
    name  = "ingress.annotations.alb\\.ingress\\.kubernetes\\.io/scheme"
    value = "internal"
  }
  set {
    name  = "ingress.annotations.alb\\.ingress\\.kubernetes\\.io/target-type"
    value = "ip"
  }
  depends_on  = [
    kubernetes_namespace.monitoring,
    helm_release.alb-controller
  ]
}

resource "helm_release" "kube_state_metrics" {
  name        = "kube-state-metrics"
  namespace   = kubernetes_namespace.monitoring.metadata[0].name
  repository  = "https://prometheus-community.github.io/helm-charts"
  chart       = "kube-state-metrics"
  version     = "5.19.0"

  set {
    name  = "serviceAccount.name"
    value = local.kube_state_metrics_service_account_name
  }
  set {
    name  = "service.type"
    value = "NodePort"
  }
  set {
    name  = "service.nodePort"
    value = 31569
  }

  depends_on  = [
    kubernetes_namespace.monitoring,
    helm_release.alb-controller
  ]
}
resource "helm_release" "cadvisor" {
  name        = "cadvisor"
  namespace   = kubernetes_namespace.monitoring.metadata[0].name
  repository  = "https://ckotzbauer.github.io/helm-charts"
  chart       = "cadvisor"
  version     = "2.3.3"

  set {
    name  = "serviceAccount.name"
    value = local.cadvisor_service_account_name
  }
  set {
    name  = "service.type"
    value = "NodePort"
  }
  set {
    name  = "container.port"
    value = 7100
  }

  depends_on  = [
    kubernetes_namespace.monitoring,
    helm_release.alb-controller
  ]
}
