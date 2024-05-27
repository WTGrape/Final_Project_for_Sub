###
# 1. dev_dmz_proxy
###
resource "aws_launch_configuration" "dev_dmz_proxy" {
  name_prefix = "dev_dmz_proxy-" 
  image_id = data.aws_ami.amazon_linux_2023.id
  instance_type = "t2.small"
  key_name = aws_key_pair.terraform_key.key_name
  security_groups = [aws_security_group.dev_dmz_proxy.id]
  associate_public_ip_address = false
  root_block_device {
    volume_type = "standard"
    volume_size = 12
  }
  ebs_block_device {
    device_name = "/dev/sdb"
    volume_type = "standard"
    volume_size = 10
    encrypted   ="false"
  }
  user_data = <<-EOF
  #!/bin/bash
  dnf install -y nginx
  systemctl enable --now nginx
  EOF
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [ aws_security_group.dev_dmz_proxy ]
}
###
# 2. user_dmz_proxy
###
resource "aws_launch_configuration" "user_dmz_proxy" {
  name_prefix = "user_dmz_proxy-" 
  image_id = data.aws_ami.amazon_linux_2023.id
  instance_type = "t2.small"
  key_name = aws_key_pair.terraform_key.key_name
  security_groups = [aws_security_group.user_dmz_proxy.id]
  associate_public_ip_address = false
  root_block_device {
    volume_type = "standard"
    volume_size = 12
  }
  ebs_block_device {
    device_name = "/dev/sdb"
    volume_type = "standard"
    volume_size = 10
    encrypted   ="false"
  }
  user_data = <<-EOF
  #!/bin/bash
  dnf install -y nginx
  systemctl enable --now nginx
  EOF
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [ aws_security_group.user_dmz_proxy ]
}
# ###
# # 3. nexus
# ###
# resource "aws_launch_configuration" "nexus" {
#   name_prefix = "nexus-" 
#   image_id = data.aws_ami.amazon_linux_2023.id
#   instance_type = "t2.small"
#   key_name = aws_key_pair.terraform_key.key_name
#   security_groups = [aws_security_group.nexus.id]
#   associate_public_ip_address = false
#   root_block_device {
#     volume_type = "standard"
#     volume_size = 12
#   }
#   ebs_block_device {
#     device_name = "/dev/sdb"
#     volume_type = "standard"
#     volume_size = 10
#     encrypted   ="false"
#   }
# #   user_data = <<-EOF
# #   #!/bin/bash
# #   dnf install -y nginx
# #   systemctl enable --now nginx
# #   echo "It is dev dmz proxy server" > /user/share/nginx/html/index.html
# #   EOF
#   lifecycle {
#     create_before_destroy = true
#   }
#   depends_on = [ aws_security_group.nexus ]
# }
# ###
# # 4. shared_int
# ###
# resource "aws_launch_configuration" "shared_int" {
#   for_each          = { for k, v in var.shared_int : k => v if lookup(v, "instance", true) != false }
#   name_prefix       = "shared_int-${each.value.name}" 
#   image_id          = data.aws_ami.amazon_linux_2023.id
#   instance_type     = "t2.small"
#   key_name          = aws_key_pair.terraform_key.key_name
#   security_groups   = concat(
#     [ aws_security_group.shared_int_default.id ],
#     [ for k, v in var.shared_int : aws_security_group.shared_int_prom-grafa.id if lookup(v, "svc_port", null) != null]
#   )
#   associate_public_ip_address = false
#   iam_instance_profile = each.value.svc_port != null ? aws_iam_instance_profile.prometheus_profile.name : null
#   root_block_device {
#     volume_type = "standard"
#     volume_size = 12
#   }
#   ebs_block_device {
#     device_name = "/dev/sdb"
#     volume_type = "standard"
#     volume_size = 10
#     encrypted   ="false"
#   }
# #   user_data = <<-EOF
# #   #!/bin/bash
# #   dnf install -y nginx
# #   systemctl enable --now nginx
# #   echo "It is dev dmz proxy server" > /user/share/nginx/html/index.html
# #   EOF
#   lifecycle {
#     create_before_destroy = true
#   }
#   depends_on = [
#     aws_security_group.shared_int_default,
#     aws_security_group.shared_int_prom-grafa
#   ]
# }