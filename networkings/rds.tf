###
# 1. test dev
###
resource "aws_db_subnet_group" "test_dev" {
  name        = "test-dev-db-subnet-group"
  subnet_ids  = aws_subnet.test_dev_db[*].id
  tags = {
    Name = "test_dev_db_subnet_group"
  }
}
resource "aws_db_instance" "test_dev" {
  identifier              = "test-dev-db"
  allocated_storage       = 20
  storage_type            = "standard"
  engine                  = "mariadb"
  engine_version          = "10.11.6"
  instance_class          = "db.t3.micro"
  db_name                 = "test_dev" # Initial Database name
  username                = "${var.db_user_name}"
  password                = "${var.db_user_pass}"
  multi_az                = true
  publicly_accessible     = false
  skip_final_snapshot     = true
  enabled_cloudwatch_logs_exports = [ "audit", "error", "general", "slowquery" ]
  db_subnet_group_name    = aws_db_subnet_group.test_dev.id
  vpc_security_group_ids  = [ aws_security_group.test_dev_db.id ]
  tags = {
    Name = "test_dev_db"
  }
}
###
# 2. production
###
resource "aws_db_subnet_group" "prod" {
  name        = "prod-db-subnet-group"
  subnet_ids  = aws_subnet.prod_db[*].id
  tags = {
    Name = "prod_db_subnet_group"
  }
}
resource "aws_db_instance" "prod" {
  identifier              = "prod-db"
  allocated_storage       = 20
  storage_type            = "standard"
  engine                  = "mariadb"
  engine_version          = "10.11.6"
  instance_class          = "db.t3.micro"
  db_name                 = "prod" # Initial Database name
  username                = "${var.db_user_name}"
  password                = "${var.db_user_pass}"
  multi_az                = true
  publicly_accessible     = false
  skip_final_snapshot     = true
  enabled_cloudwatch_logs_exports = [ "audit", "error", "general", "slowquery" ]
  db_subnet_group_name    = aws_db_subnet_group.prod.id
  vpc_security_group_ids  = [ aws_security_group.prod_db.id ]
  tags = {
    Name = "prod_db"
  }
}