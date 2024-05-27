locals {
  lb_controller_iam_role_name        = "test-dev-inhouse-eks-aws-lb-ctrl" 
  lb_controller_service_account_name = "test-dev-aws-load-balancer-controller"
  node_exporter_service_account_name      = "test-dev-node-exporter"
  cadvisor_service_account_name           = "test-dev-cadvisor"
  kube_state_metrics_service_account_name = "test-dev-kube-state-metrics"
  region                             = "ap-northeast-2"
}
