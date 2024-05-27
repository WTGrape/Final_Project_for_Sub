output "dev_dmz_nlb_dns_name" {
  value = aws_lb.dev_dmz_nlb.dns_name
}
output "dev_dmz_alb_dns_name" {
  value = aws_lb.dev_dmz_alb[*].dns_name
}
output "user_dmz_dns_name" {
  value = aws_lb.user_dmz_alb[*].dns_name
}
output "shared_int_dns_name" {
  value = aws_lb.shared_int.dns_name
}
output "shared_ext_lb_network_interface_ips" {
  value = "${flatten([data.aws_network_interface.shared_ext[*].private_ips])}"
}