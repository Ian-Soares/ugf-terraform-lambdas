module "lambda_function" {
  source = "../lambda-function"

  create      = try(var.create_lambda_function, true)
  name        = var.lambda_function_name
  description = try(var.lambda_function_description, "")
  handler     = try(var.lambda_function_handler, "lambda_function.lambda_handler")
  runtime     = try(var.lambda_function_runtime, "python3.8")
  timeout     = try(var.lambda_function_timeout, 120)
  memory_size = try(var.lambda_function_memory_size)

  source_code_path = var.lambda_function_source_code_path
  vpc_config = try(var.lambda_vpc_config, null) != null ? {
    subnet_ids         = var.lambda_vpc_config.subnet_ids
    security_group_ids = var.lambda_vpc_config.security_group_ids
  } : null
  env                = var.lambda_function_env
  custom_policy_arns = try(concat(var.lambda_function_custom_policy_arns, ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/sns-publish-policy-${random_id.id.hex}"]), ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/sns-publish-policy-${random_id.id.hex}"])
  tags               = merge(var.lambda_function_tags, var.default_tags)

  depends_on = [
    aws_iam_policy.sns_publish
  ]
}

module "sns_topic" {
  source = "terraform-aws-modules/sns/aws"

  create = try(var.create_sns_topic, true)
  name   = var.sns_topic_name

  subscriptions = try(var.sns_topic_subscriptions, [])

  tags = merge(var.sns_topic_tags, var.default_tags)
}

resource "aws_iam_policy" "sns_publish" {
  name        = "sns-publish-policy-${random_id.id.hex}"
  description = "IAM policy for publishing to the SNS topic"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "sns:Publish"
        Resource = module.sns_topic.topic_arn
      },
    ]
  })
}

resource "random_id" "id" {
  byte_length = 8
}