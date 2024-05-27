###
# 1. promethus role
###
resource "aws_iam_role" "prometheus_role" {
  name               = "prometheus_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
     }
   ]
  }
  EOF
}
resource "aws_iam_policy" "prometheus_ec2_policy" {
  name        = "prometheus_ec2_policy"
  path        = "/"
  description = "My prometheus policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}
resource "aws_iam_policy_attachment" "prometheus_ec2_policy" {
  name       = "prometheus_role-Attachment"
  roles      = [aws_iam_role.prometheus_role.name]
  policy_arn = aws_iam_policy.prometheus_ec2_policy.arn
}
resource "aws_iam_instance_profile" "prometheus_profile" {
  name = "prometheus-profile"
  role = aws_iam_role.prometheus_role.name
}