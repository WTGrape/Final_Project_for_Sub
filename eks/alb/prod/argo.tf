resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "null_resource" "argocd" {
  triggers = {
    always_recreate = "${timestamp()}"
  }
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "kubectl apply -n argocd -f ${var.argo_manifest}"
  }
  depends_on = [
    kubernetes_namespace.argocd,
    helm_release.alb-controller,
    helm_release.node_exporter
  ]
}
