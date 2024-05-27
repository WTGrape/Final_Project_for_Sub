###
# 1. argo manifest
###
variable "argo_manifest" {
    type        = string
    default = "https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"
}