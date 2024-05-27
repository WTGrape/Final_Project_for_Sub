###
# 1. Lambda for cloudtrail
###
resource "aws_lambda_function" "cloudwatch_to_opensearch" {
  filename      = data.archive_file.lambda.output_path
  function_name = "cloudwatch_to_opensearch"
  role          = aws_iam_role.role-cloudwatch-to-opensearch.arn
  handler       = "index.handler"
  source_code_hash = data.archive_file.lambda.output_base64sha256
  runtime = "nodejs18.x"
  vpc_config {
    subnet_ids         = data.aws_subnets.shared_int.ids
    security_group_ids = data.aws_security_groups.shared_opensearch.ids
  }
}
resource "aws_lambda_permission" "logging" {
  depends_on    = [aws_lambda_function.cloudwatch_to_opensearch]
  statement_id  = "InvokeFunction-for-opensearch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.cloudwatch_to_opensearch.arn}"
  principal     = "logs.amazonaws.com"
  source_arn    = "${aws_cloudwatch_log_group.log_cloudtrail.arn}:*"
}
resource "aws_cloudwatch_log_subscription_filter" "cloudwatch_lambdafunction_logfilter" {
  depends_on    = [aws_lambda_function.cloudwatch_to_opensearch]
  name            = "cloudwatch_to_opensearch"
  log_group_name  = "/aws/nadri-cloudtrail"
  filter_pattern  = ""
  destination_arn = aws_lambda_function.cloudwatch_to_opensearch.arn
}
###
# 2-1. Lambda for firehose transformation (DB)
###
resource "aws_lambda_function" "lambda_to_firehose" {
  for_each      = var.transform  
  filename      = data.archive_file.transform[each.key].output_path
  function_name = "${each.value.name}-transformation"
  role          = aws_iam_role.role-lambda-to-firehose.arn
  handler       = "${each.value.name}.lambda_handler"
  source_code_hash = data.archive_file.transform[each.key].output_base64sha256
  runtime = "python3.10"
  timeout = "90"
  vpc_config {
    subnet_ids         = data.aws_subnets.shared_int.ids
    security_group_ids = data.aws_security_groups.shared_opensearch.ids
  }
  depends_on = [ data.archive_file.transform ]
}
###
# 2-2. Lambda for firehose transformation (vpc-flow)
###
resource "aws_lambda_function" "lambda_to_firehose_vpc_flow" {
  for_each      = { for k, v in var.firehose_connection : k => v if lookup(v, "lambda", false) != null }
  filename      = data.archive_file.vpc_transform[each.key].output_path
  function_name = "${each.value.lambda}"
  role          = aws_iam_role.role-lambda-to-firehose.arn
  handler       = "${each.value.handler}.lambda_handler"
  source_code_hash = data.archive_file.vpc_transform[each.key].output_base64sha256
  runtime = "python3.9"
  timeout = "90"
  vpc_config {
    subnet_ids         = data.aws_subnets.shared_int.ids
    security_group_ids = data.aws_security_groups.shared_opensearch.ids
  }
  depends_on = [ data.archive_file.vpc_transform ]
}
###
# 2-3. Lambda for firehose transformation (wafs)
###
resource "aws_lambda_function" "lambda_to_firehose_waf" {
  filename      = data.archive_file.waf_transform.output_path
  function_name = "aws-waf-logs"
  role          = aws_iam_role.role-lambda-to-firehose.arn
  handler       = "waf-lambda.lambda_handler"
  source_code_hash = data.archive_file.waf_transform.output_base64sha256
  runtime = "python3.9"
  timeout = "90"
  vpc_config {
    subnet_ids         = data.aws_subnets.shared_int.ids
    security_group_ids = data.aws_security_groups.shared_opensearch.ids
  }
  depends_on = [ data.archive_file.waf_transform ]
}