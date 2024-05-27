###
# 1. policy
###
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}
resource "aws_iam_policy" "nginx_conf_lambda" {
  name = "nginx-conf-lambda"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "arn:aws:logs:${local.region}:${data.aws_caller_identity.current.account_id}:*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:${local.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/nginx_config:*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateNetworkInterface",
                "ec2:DeleteNetworkInterface",
                "ec2:DescribeNetworkInterfaces"
            ],
            "Resource": "*"
        }
    ]
})
  depends_on = [aws_iam_role.nginx_conf_lambda]
}
###
# 2. role
###
resource "aws_iam_role" "nginx_conf_lambda" {
  name               = "nginx-conf-lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}
resource "aws_iam_role_policy_attachment" "nginx-conf-ec2-read" {
  role      = aws_iam_role.nginx_conf_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}
resource "aws_iam_role_policy_attachment" "nginx-conf-ASG-read" {
  role      = aws_iam_role.nginx_conf_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/AutoScalingReadOnlyAccess"
}
resource "aws_iam_role_policy_attachment" "nginx-conf-custom" {
  role      = aws_iam_role.nginx_conf_lambda.name
  policy_arn = aws_iam_policy.nginx_conf_lambda.arn
}
###
# 3. function
###
resource "aws_lambda_function" "nginx_conf_lambda" {
  for_each = var.lambda
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "../files/${each.value.name}-nginx-conf.zip"
  function_name = "${each.value.name}-nginx-conf"
  role          = aws_iam_role.nginx_conf_lambda.arn
  handler       = "lambda_function.lambda_handler"
  layers = [aws_lambda_layer_version.lambda_layer[each.key].arn]
  # source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.9"
  timeout = 60
  vpc_config {
  # Every subnet should be able to reach an EFS mount target in the same Availability Zone. Cross-AZ mounts are not permitted.
  subnet_ids         = data.aws_subnets.shared.ids[*]
  security_group_ids = [ data.aws_security_group.shared_default.id ]
  }
  depends_on = [ aws_iam_role.nginx_conf_lambda ]
}

resource "aws_lambda_layer_version" "lambda_layer" {
  for_each = var.lambda
  filename   = "../files/layer.zip"
  layer_name = "${each.value.name}-nginx-conf"
  compatible_architectures = [ "x86_64" ] 
  compatible_runtimes = ["python3.9"]
}