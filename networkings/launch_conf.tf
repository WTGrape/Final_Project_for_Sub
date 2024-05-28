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
