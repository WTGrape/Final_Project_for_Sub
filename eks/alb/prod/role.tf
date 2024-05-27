###
# 1. lb controller role
###
module "lb_controller_role" { 
  source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc" 
  create_role = true 
  role_name        = local.lb_controller_iam_role_name 
  role_path        = "/" 
  role_description = "Used by AWS Load Balancer Controller for EKS" 
  role_permissions_boundary_arn = "" 
  provider_url       = replace(data.aws_iam_openid_connect_provider.prod_was.url, "https://", "") 
  oidc_fully_qualified_subjects = [ 
    "system:serviceaccount:kube-system:${local.lb_controller_service_account_name}" 
  ] 
  oidc_fully_qualified_audiences = [ 
    "sts.amazonaws.com" 
  ] 
}

resource "aws_iam_role_policy" "controller" { 
  name_prefix = "AWSLoadBalancerControllerIAMPolicy" 
  policy      = data.http.iam_policy.body 
  role        = module.lb_controller_role.iam_role_name 
} 