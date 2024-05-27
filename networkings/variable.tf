###
# 1. Key Variables 
###
variable "key_name" {
  description = "Name of the key pair"
  type        = string
  default     = "terraform-key"
  sensitive = true
}
variable "public_key_location" {
  description = "Location of the Public key"
  type        = string
  default     = "~/.ssh/terraform-key.pub"
  sensitive = true
}
variable "private_key_location" {
  description = "Location of the private key"
  type        = string
  default     = "~/.ssh/terraform-key"
  sensitive = true
}
###
# 2. tags
###
variable "dmz_tags" {
  type = map(string)
  description = "(optional) default tags for dmz"
  default = {
    Area   = "dmz"
  }
}
variable "shared_tags" {
  type = map(string)
  description = "(optional) default tags for shared"
  default = {
    Area   = "shared"
  }
}
variable "dev_tags" {
  type = map(string)
  description = "(optional) default tags for dev"
  default = {
    User   = "dev"
  }
}
variable "user_tags" {
  type = map(string)
  description = "(optional) default tags for dev"
  default = {
    User   = "user"
  }
}
variable "test_tags" {
  type = map(string)
  description = "(optional) default tags for Test"
  default = {
    Environment   = "test"
  }
}
variable "prod_tags" {
  type = map(string)
  description = "(optional) default tags for prod"
  default = {
    Environment   = "prod"
  }
}
###
# 3. shared int
###
variable "shared_int" {
  type = map(object({
    name        = string
    svc_name    = optional(string)
    port        = optional(string)
    svc_port    = optional(string)
    listener    = optional(string)
    dmz_listen  = optional(string)
    instance    = bool
  }))
  default = {
    "prom-grafa" = {
      name        = "prom-grafa"
      svc_name    = "prometheus"
      port        = "1000"
      svc_port    = "9090"
      listener    = "1000"
      dmz_listen  = "8888"
      instance    = true
    },
    "grafana" = {
      name        = "grafana"
      svc_name    = "grafana"
      svc_port    = "3000"
      listener    = "2000"
      dmz_listen  = "7777"
      instance    = false
    },
    "eks_master" = {
      name        = "eks-master"
      port        = "3000"
      instance    = true
    },
    "db_control" = {
      name        = "db-control"
      port        = "2000"
      instance    = true
    },
  }
}
###
# 4. RDS Variables 
###
variable "db_user_name" { 
  description = "Database User Name" 
  type        = string
  default     = "nana"
  sensitive = true
}
variable "db_user_pass" { 
  description = "Database User Password" 
  type        = string 
  default     = "nana!12345"
  sensitive = true
}
###
# 5. endpoints for eks
###
variable "interface_endpoints" {
  type = map(object({
    name         = string
    service_name = string
    type         = string
  }))
  default = {
    "ecr-api" = {
      name         = "ecr-api"
      service_name = "com.amazonaws.ap-northeast-2.ecr.api"
      type         = "Interface"
    },
    "ecr-dkr" = {
      name         = "ecr-dkr"
      service_name = "com.amazonaws.ap-northeast-2.ecr.dkr"
      type         = "Interface"
    },
    "ec2" = {
      name         = "ec2"
      service_name = "com.amazonaws.ap-northeast-2.ec2"
      type         = "Interface"
    },
    "elb" = {
      name         = "elb"
      service_name = "com.amazonaws.ap-northeast-2.elasticloadbalancing"
      type         = "Interface"
    },
    "logs" = {
      name         = "logs"
      service_name = "com.amazonaws.ap-northeast-2.logs"
      type         = "Interface"
    },
    "sts" = {
      name         = "sts"
      service_name = "com.amazonaws.ap-northeast-2.sts"
      type         = "Interface"
    },
    "xray" = {
      name         = "xray"
      service_name = "com.amazonaws.ap-northeast-2.xray"
      type         = "Interface"
    },
    "s3" = {
      name         = "s3"
      service_name = "com.amazonaws.ap-northeast-2.s3"
      type         = "Interface"
    },
    "autoscaling" = {
      name         = "autoscaling"
      service_name = "com.amazonaws.ap-northeast-2.autoscaling"
      type         = "Interface"
    },
    "aps" = {
      name         = "aps"
      service_name = "com.amazonaws.ap-northeast-2.aps"
      type         = "Interface"
    },
    "aps-workspaces" = {
      name         = "aps-workspaces"
      service_name = "com.amazonaws.ap-northeast-2.aps-workspaces"
      type         = "Interface"
    }
  }
}
###
# 6. rules
###
variable "rules" {
  type    = list(any)
  default = [
    # linux os rule
    {
      name     = "AWSManagedRulesLinuxRuleSet"
      priority = 10
      aws_rg_name = "AWSManagedRulesLinuxRuleSet"
      aws_rg_vendor_name = "AWS"
      metric_name = "AWSManagedRulesLinuxRuleSetMetric"
      allow       = []
      block = [
        "LFI_URIPATH",
        "LFI_QUERYSTRING",
        "LFI_HEADER"
      ]
      captcha   = []
      challenge = []
      count     = []
    },
    # SQL database rule (SQL injection)
    {
      name     = "AWSManagedRulesSQLiRuleSet"
      priority = 20
      aws_rg_name = "AWSManagedRulesSQLiRuleSet"
      aws_rg_vendor_name = "AWS"
      metric_name = "AWSManagedRulesSQLiRuleSetMetric"
      allow       = []
      block = [
        "SQLi_QUERYARGUMENTS",
        "SQLiExtendedPatterns_QUERYARGUMENTS",
        "SQLi_BODY",
        "SQLiExtendedPatterns_BODY",
        "SQLi_COOKIE",
      ]
      captcha   = []
      challenge = []
      count     = []
    },
    # core rule set (CRS) rule XSS
    {
      name     = "AWSManagedRulesCommonRuleSet"
      priority = 30
      aws_rg_name = "AWSManagedRulesCommonRuleSet"
      aws_rg_vendor_name = "AWS"
      metric_name = "AWSManagedRulesCommonRuleSetMetric"
      allow = [
        "SizeRestrictions_BODY",
        "CrossSiteScripting_BODY"
      ]
      block = [
        "NoUserAgent_HEADER",
        "UserAgent_BadBots_HEADER",
        "SizeRestrictions_QUERYSTRING",
        "SizeRestrictions_Cookie_HEADER",
        "SizeRestrictions_URIPATH",
        "EC2MetaDataSSRF_BODY",
        "EC2MetaDataSSRF_COOKIE",
        "EC2MetaDataSSRF_URIPATH",
        "EC2MetaDataSSRF_QUERYARGUMENTS",
        "GenericLFI_QUERYARGUMENTS",
        "CrossSiteScripting_URIPATH",
        "GenericLFI_URIPATH",
        "GenericLFI_BODY",
        "RestrictedExtensions_URIPATH",
        "RestrictedExtensions_QUERYARGUMENTS",
        "GenericRFI_QUERYARGUMENTS",
        "GenericRFI_BODY",
        "GenericRFI_URIPATH",
        "CrossSiteScripting_COOKIE",
        "CrossSiteScripting_QUERYARGUMENTS",
      ]
      captcha   = []
      challenge = []
      count     = []
    },
    # posix os rule
    {
      name     = "AWSManagedRulesUnixRuleSet"
      priority = 40
      aws_rg_name = "AWSManagedRulesUnixRuleSet"
      aws_rg_vendor_name = "AWS"
      metric_name = "AWSManagedRulesUnixRuleSetMetric"
      allow       = []
      block = [
        "UNIXShellCommandsVariables_QUERYARGUMENTS",
        "UNIXShellCommandsVariables_BODY",
        "UNIXShellCommandsVariables_HEADER_RC_COUNT",
        "UNIXShellCommandsVariables_BODY_RC_COUNT",
        "UNIXShellCommandsVariables_QUERYSTRING_RC_COUNT"
      ]
      captcha   = []
      challenge = []
      count     = []
    },
    # amazon IP reputation list managed rule
    {
      name     = "AWSManagedRulesAmazonIpReputationList"
      priority = 50
      aws_rg_name = "AWSManagedRulesAmazonIpReputationList"
      aws_rg_vendor_name = "AWS"
      metric_name = "AWSManagedRulesAmazonIpReputationListmetric"
      allow       = []
      block = [
        "AWSManagedIPReputationList",
        "AWSManagedReconnaissanceList",
        "AWSManagedIPDDoSList"
      ]
      captcha   = []
      challenge = []
      count     = []
    },
    # anonymous IP list rule
    {
      name     = "AWSManagedRulesAnonymousIpList"
      priority = 60
      aws_rg_name = "AWSManagedRulesAnonymousIpList"
      aws_rg_vendor_name = "AWS"
      metric_name = "AWSManagedRulesAnonymousIpList"
      allow       = []
      block = [
        "AnonymousIPList",
        "HostingProviderIPList"
      ]
      captcha   = []
      challenge = []
      count     = []
    },
    # # Known Bad Inputs Rule Set
    # {
    #   name        = "AWSManagedRulesKnownBadInputsRuleSet"
    #   priority    = 5
    #   aws_rg_name = "AWSManagedRulesKnownBadInputsRuleSet"
    #   aws_rg_vendor_name = "AWS"
    #   metric_name = "AWSManagedRulesKnownBadInputsRuleSet"
    #   allow       = []
    #   block = [
    #     "JavaDeserializationRCE_HEADER",
    #     "JavaDeserializationRCE_BODY",
    #     "JavaDeserializationRCE_URIPATH",
    #     "JavaDeserializationRCE_QUERYSTRING",
    #     "Host_localhost_HEADER",
    #     "PROPFIND_METHOD",
    #     "ExploitablePaths_URIPATH",
    #     "Log4JRCE_HEADER",
    #     "Log4JRCE_QUERYSTRING",
    #     "Log4JRCE_BODY",
    #     "Log4JRCE_URIPATH",
    #   ]
    #   captcha   = []
    #   challenge = []
    #   count     = []
    #   },
    # Bot Control Rule Set
    {
      name        = "AWSManagedRulesBotControlRuleSet"
      priority    = 6
      aws_rg_name = "AWSManagedRulesBotControlRuleSet"
      aws_rg_vendor_name = "AWS"
      metric_name = "AWSManagedRulesBotControlRuleSet"
      allow = [
        "SignalAutomatedBrowser",
        "CategoryHttpLibrary",
        "SignalNonBrowserUserAgent"
      ]
      block     = []
      captcha   = []
      challenge = []
      count = [
        "CategoryAdvertising",
        "CategoryArchiver",
        "CategoryContentFetcher",
        "CategoryEmailClient",
        "CategoryLinkChecker",
        "CategoryMiscellaneous",
        "CategoryMonitoring",
        "CategoryScrapingFramework",
        "CategorySearchEngine",
        "CategorySecurity",
        "CategorySeo",
        "CategorySocialMedia",
        "CategoryAI",
        "SignalKnownBotDataCenter"
      ]
    }       
  ]
}