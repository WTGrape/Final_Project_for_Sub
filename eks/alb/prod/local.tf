locals { 
  lb_controller_iam_role_name         = "prod-inhouse-eks-aws-lb-ctrl" 
  lb_controller_service_account_name  = "prod-aws-load-balancer-controller"
  region                              = "ap-northeast-2"
  node_exporter_service_account_name      = "prod-node-exporter"
  cadvisor_service_account_name           = "prod-cadvisor"
  kube_state_metrics_service_account_name = "prod-kube-state-metrics"
  click_name                          = ["nadri-project.click","www.nadri-project.click","argo.nadri-project.click"]
} 