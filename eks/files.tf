###
# 1. config nexus
###
resource "null_resource" "copy_files" {
  triggers = {
    always_recreate = "${timestamp()}"
  }
  connection {
    type = "ssh"
    user = "ec2-user"
    private_key = "${file("~/.ssh/terraform-key")}"
    host = "${data.aws_lb.dev_dmz_lb.dns_name}"
    port = 9999
  }
  provisioner "file" {
    source      = var.private_key_location
    destination = "${var.dest1}"
  }
  provisioner "file" {
    source      = "~/.aws"
    destination = "${var.dest2}"
  }
  provisioner "file" {
    source      = "./alb"
    destination = "${var.dest3}"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo chmod 600 ${var.dest1}",
      "sudo chown ec2-user:ec2-user ${var.dest1}",
      "sudo chown ec2-user:ec2-user ${var.dest2}",
    ]
  }
}
###
# 2. copy to eks contorller
###
resource "null_resource" "copy_test_dev" {
  triggers = {
    always_recreate = "${timestamp()}"
  }
  connection {
    type = "ssh"
    user = "ec2-user"
    private_key = "${file("~/.ssh/terraform-key")}"
    host = "${data.aws_lb.dev_dmz_lb.dns_name}"
    port = 9999
  }
  provisioner "remote-exec" {
    inline = [
      "sudo scp -i ${var.dest1} -o StrictHostKeyChecking=no -P 3000 -r ${var.dest3}/test_dev ec2-user@${data.aws_lb.shared_int_lb.dns_name}:.",
      "sudo scp -i ${var.dest1} -o StrictHostKeyChecking=no -P 3000 -r ${var.dest2} ec2-user@${data.aws_lb.shared_int_lb.dns_name}:.",
      "sudo rm -rf ${var.dest3}/test_dev"
    ]
  }
  depends_on = [ null_resource.copy_files ]
}

resource "null_resource" "copy_prod" {
  triggers = {
    always_recreate = "${timestamp()}"
  }
  connection {
    type = "ssh"
    user = "ec2-user"
    private_key = "${file("~/.ssh/terraform-key")}"
    host = "${data.aws_lb.dev_dmz_lb.dns_name}"
    port = 9999
  }
  provisioner "remote-exec" {
    inline = [
      "sudo scp -i ${var.dest1} -o StrictHostKeyChecking=no -P 3000 -r ${var.dest3}/prod prod@${data.aws_lb.shared_int_lb.dns_name}:.",
      "sudo scp -i ${var.dest1} -o StrictHostKeyChecking=no -P 3000 -r ${var.dest2} prod@${data.aws_lb.shared_int_lb.dns_name}:.",
      "sudo rm -rf ${var.dest3}"
    ]
  }
  depends_on = [
    null_resource.copy_files, 
    # null_resource.prod_user
    ]
}

###
# 3. copy to prometheus cred
###
resource "null_resource" "prometheus_cred" {
  triggers = {
    always_recreate = "${timestamp()}"
  }
  connection {
    type = "ssh"
    user = "ec2-user"
    private_key = "${file("~/.ssh/terraform-key")}"
    host = "${data.aws_lb.dev_dmz_lb.dns_name}"
    port = 9999
  }
  provisioner "remote-exec" {
    inline = [
      "sudo scp -i ${var.dest1} -o StrictHostKeyChecking=no -P 1000 -r ${var.dest2} ec2-user@${data.aws_lb.shared_int_lb.dns_name}:.",
    ]
  }
  depends_on = [ null_resource.copy_files ]
}