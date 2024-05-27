###
# pod security group ids
###
# output "test_dev_pod_sg" {
#     value = data.aws_security_group.test_dev_pod_security_group.id
# }
# output "prod_pod_sg" {
#     value = data.aws_security_group.prod_pod_security_group.id
# }
###
# 1. test dev rds endpoint
###
output "test_dev_rds_endpoint" {
    value = data.aws_db_instance.test_dev.endpoint
}