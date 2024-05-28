resource "aws_instance" "nexus" {
  ami = data.aws_ami.amazon_linux_2023.id
  instance_type = "t2.small" 
  vpc_security_group_ids = [aws_security_group.nexus.id]
  key_name = aws_key_pair.terraform_key.key_name
  subnet_id = aws_subnet.nexus[0].id
  associate_public_ip_address = false

  tags = merge(var.shared_tags,var.dev_tags,
    {
      Name        = "nexus"
    }
  )
  depends_on = [
    aws_subnet.nexus,
    aws_security_group.nexus
  ]
}
resource "aws_instance" "shared_int" {
  for_each         = { for k, v in var.shared_int : k => v if lookup(v, "instance", true) != false }
  ami = data.aws_ami.amazon_linux_2023.id
  instance_type = "t2.small" 
  vpc_security_group_ids = concat(
    [ aws_security_group.shared_int_default.id ],
    [ for k, v in var.shared_int : aws_security_group.shared_int_prom-grafa.id if lookup(v, "svc_port", null) != null]
  )
  user_data = "${file("../files/${each.value.name}.sh")}"
  iam_instance_profile = each.value.svc_port != null ? aws_iam_instance_profile.prometheus_profile.name : null
  key_name = aws_key_pair.terraform_key.key_name
  subnet_id = aws_subnet.shared_int[0].id
  associate_public_ip_address = false

  tags = merge(var.shared_tags,var.dev_tags,
    {
      Name = each.value.name
    }
  )
  depends_on = [
    aws_lb.shared_ext,
    aws_subnet.shared_int,
    aws_security_group.shared_int_default,
    aws_security_group.shared_int_prom-grafa
  ]
}