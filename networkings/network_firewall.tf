##############################################################################
########################### 1. NWF rule group #############################
##############################################################################

####################### a. nwf deafault ssh ########################
resource "aws_networkfirewall_rule_group" "nwf_rule_group" {
  capacity = 1000
  name     = "nwf-rule-group"
  type     = "STATELESS"
  rule_group {
    rules_source {      
      stateless_rules_and_custom_actions {
        stateless_rule {
          priority = 1      
          rule_definition {
            actions = ["aws:forward_to_sfe"]             
            match_attributes {
              source {
                address_definition = "213.0.113.0/24"
              }
              source_port {
                from_port = 9999
                to_port   = 9999
              }
              destination {
                address_definition = aws_subnet.dev_dmz_lb[0].cidr_block
              }
              destination_port {
                from_port = 9999
                to_port   = 9999
              }
              protocols = [6]
            #   tcp_flag {
            #     flags = ["SYN"]
            #     masks = ["SYN", "ACK"]                   
            # }
            }     
          }
        }
        # for nexus no.2
        # stateless_rule {
        #   priority = 2
        #   rule_definition {
        #     actions = ["aws:pass"]
        #     match_attributes {
        #       source {
        #         address_definition = "213.0.113.0/24"
        #       }
        #       source_port {
        #         from_port = 8888
        #         to_port   = 8888
        #       }
        #       destination {
        #         address_definition = aws_subnet.subnet_dev_dmz_pub[5].cidr_block
        #       }
        #       destination_port {
        #         from_port = 8888
        #         to_port   = 8888
        #       }
        #       protocols = [6]              
        #     }     
        #   }
        # }            
      }      
    }
  }
}        

####################### b. allow local rule ########################
# resource "aws_networkfirewall_rule_group" "allow-local" {
#   capacity = 1000
#   name     = "allow-local-ranges"
#   type     = "STATELESS"
#   rule_group {
#     rules_source {
#       stateless_rules_and_custom_actions {
#         stateless_rule {
#           priority = 5
#           rule_definition {
#             actions = ["aws:pass"]
#             match_attributes {
#               source {
#                 address_definition = "10.0.0.0/8"
#               }
#               # source {
#               #   address_definition = "192.168.0.0/16"
#               # }
#             }
#           }
#         }
#       }
#     }
#   }
# }

####################### c. deny all http ########################
# resource "aws_networkfirewall_rule_group" "deny-http" {
#   capacity = 100
#   name     = "deny-http"
#   type     = "STATEFUL"
#   rule_group {
#     rules_source {
#       stateful_rule {
#         action = "DROP"
#         header {
#           destination      = aws_subnet.user_dmz_lb[0].cidr_block
#           destination_port = 80
#           direction        = "ANY"
#           protocol         = "HTTP"
#           source           = "0.0.0.0/0"
#           source_port      = 80
#         }
#         rule_option {
#           keyword = "sid:1"
#         }
#       }
#       stateful_rule {
#         action = "DROP"
#         header {
#           destination      = aws_subnet.user_dmz_lb[1].cidr_block
#           destination_port = 80
#           direction        = "ANY"
#           protocol         = "HTTP"
#           source           = "0.0.0.0/0"
#           source_port      = 80
#         }
#         rule_option {
#           keyword = "sid:2"
#         }
#       }      
#     }
#   }

#   tags = {
#     "Name" = "deny-http"
#   }
# }

####################### d. deny all ssh ########################
resource "aws_networkfirewall_rule_group" "deny-ssh" {
  capacity = 100
  name     = "deny-ssh"
  type     = "STATEFUL"
  rule_group {
    rules_source {
      stateful_rule {
        action = "DROP"
        header {
          destination      = aws_subnet.user_dmz_lb[0].cidr_block
          destination_port = 22
          direction        = "ANY"
          protocol         = "SSH"
          source           = "0.0.0.0/0"
          source_port      = 22
        }
        rule_option {
          keyword = "sid:1"
        }
      }
      stateful_rule {
        action = "DROP"
        header {
          destination      = aws_subnet.user_dmz_lb[0].cidr_block
          destination_port = 22
          direction        = "ANY"
          protocol         = "SSH"
          source           = "0.0.0.0/0"
          source_port      = 22
        }
        rule_option {
          keyword = "sid:2"
        }
      }       
    }
  }

  tags = {
    "Name" = "deny-ssh"
  }
}        

##############################################################################
############################### 2. NWF Policy ################################
##############################################################################

resource "aws_networkfirewall_firewall_policy" "nwf_policy" {
  name = "nwf-policy"
  firewall_policy {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]
    # stateful_default_actions           = ["aws:forward_to_sfe"]
    stateful_engine_options {
      rule_order = "DEFAULT_ACTION_ORDER"
    }

    stateless_rule_group_reference {
      priority     = 1  
      resource_arn = aws_networkfirewall_rule_group.nwf_rule_group.arn
    }

    # stateless_rule_group_reference {
    #   priority     = 2  
    #   resource_arn = aws_networkfirewall_rule_group.allow-local.arn
    # }  

    stateful_rule_group_reference {    
      # priority     = 1      
      resource_arn = aws_networkfirewall_rule_group.deny-ssh.arn
    }  

    # stateful_rule_group_reference {
    #   # priority     = 2      
    #   resource_arn = aws_networkfirewall_rule_group.deny-http.arn
    # }  
    # 알려지고 확인된 활성 봇넷과 기타 명령 및 제어(C2) 호스트의 여러 소스에서 자동 생성된 서명(s)    
    stateful_rule_group_reference {
      resource_arn = "arn:aws:network-firewall:ap-northeast-2:aws-managed:stateful-rulegroup/ThreatSignaturesBotnetActionOrder"
    }
    # HTTP 봇넷을 탐지하는 서명
    stateful_rule_group_reference {
      resource_arn = "arn:aws:network-firewall:ap-northeast-2:aws-managed:stateful-rulegroup/ThreatSignaturesBotnetWebActionOrder"
    }
    # 코인 채굴을 수행하는 악성 코드를 탐지하는 규칙이 포함된 서명
    stateful_rule_group_reference {
      resource_arn = "arn:aws:network-firewall:ap-northeast-2:aws-managed:stateful-rulegroup/ThreatSignaturesMalwareCoinminingActionOrder"
    }         
    # 합법적이지만 손상되어 멜웨어를 호스팅을 할 수 있는 도메인 클래스에 대한 차단
    stateful_rule_group_reference {
      resource_arn = "arn:aws:network-firewall:ap-northeast-2:aws-managed:stateful-rulegroup/AbusedLegitMalwareDomainsActionOrder"
    }    
    # 봇넷을 호스팅하는 것으로 알려진 도메인에 대한 요청을 차단
    stateful_rule_group_reference {
      resource_arn = "arn:aws:network-firewall:ap-northeast-2:aws-managed:stateful-rulegroup/BotNetCommandAndControlDomainsActionOrder"
    }
  }
  depends_on = [ 
    # aws_networkfirewall_rule_group.allow-local,
    # aws_networkfirewall_rule_group.deny-http,
    aws_networkfirewall_rule_group.deny-ssh,
    aws_networkfirewall_rule_group.nwf_rule_group,
   ]
}   
##############################################################################
############################ 3. Network Firewall #############################
##############################################################################

resource "aws_networkfirewall_firewall" "user_network_firewall" { 
  name                               = "${local.user_dmz_name}-nwf"
  firewall_policy_arn                = aws_networkfirewall_firewall_policy.nwf_policy.arn
  vpc_id                             = aws_vpc.user_dmz.id
  # 나중에 true로 변경
  firewall_policy_change_protection  = false
  subnet_change_protection           = false
  subnet_mapping {
    subnet_id                        = aws_subnet.user_dmz_nwf[0].id
  }
  subnet_mapping {
    subnet_id                        = aws_subnet.user_dmz_nwf[1].id
  }
  tags = {
    Name                             = "${local.user_dmz_name}-nwf" 
  }
}

resource "aws_networkfirewall_firewall" "dev_network_firewall" { 
  name                               = "${local.dev_dmz_name}-nwf"
  firewall_policy_arn                = aws_networkfirewall_firewall_policy.nwf_policy.arn
  vpc_id                             = aws_vpc.dev_dmz.id
  # 나중에 true로 변경
  firewall_policy_change_protection  = false
  subnet_change_protection           = false
  subnet_mapping {
    subnet_id                        = aws_subnet.dev_dmz_nwf[0].id
  }
  subnet_mapping {
    subnet_id                        = aws_subnet.dev_dmz_nwf[1].id
  }
  tags = {
    Name                             = "${local.dev_dmz_name}-nwf" 
  }
}  
#   timeouts {
#     create = "20m"
#     update = "20m"
#     delete = "20m"
#   }