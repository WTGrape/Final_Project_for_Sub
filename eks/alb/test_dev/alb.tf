###
# 1. lb controller
###
resource "helm_release" "alb-controller" { 
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts" 
  chart      = "aws-load-balancer-controller" 
  namespace  = "kube-system" 
 
  set { 
    name  = "region" 
    value = local.region 
  } 
  set { 
    name  = "vpcId" 
    value = data.aws_vpc.test_dev_vpc.id
  } 
  set { 
    name  = "image.repository" 
    value = "602401143452.dkr.ecr.us-east-2.amazonaws.com/amazon/aws-load-balancer-controller" 
  } 
  set { 
    name  = "serviceAccount.create" 
    value = "true" 
  } 
  set { 
    name  = "serviceAccount.name" 
    value = local.lb_controller_service_account_name 
  }
  set { 
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.lb_controller_role.iam_role_arn
  } 
  set { 
    name  = "clusterName" 
    value = "test_dev_was" 
  }
  set { 
    name  = "enableShield" 
    value = "false" 
  }
  set { 
    name  = "enableWaf" 
    value = "false" 
  }
  set { 
    name  = "enableWafv2" 
    value = "false" 
  }
  depends_on = [ module.lb_controller_role ]
} 