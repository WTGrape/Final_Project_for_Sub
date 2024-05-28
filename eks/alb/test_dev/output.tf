###
# 1. test dev rds endpoint
###
output "test_dev_rds_endpoint" {
    value = data.aws_db_instance.test_dev.endpoint
}