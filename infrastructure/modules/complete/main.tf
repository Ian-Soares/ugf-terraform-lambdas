locals {
  custom_policy_arns = var.create_sns_topic == true ? (
    concat(var.lambda_function_custom_policy_arns, ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/sns-publish-policy-${random_id.id.hex}"])
  ) : var.lambda_function_custom_policy_arns
  number_of_custom_policy_attachments = length(local.custom_policy_arns)
}

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
  env                                 = var.lambda_function_env
  number_of_custom_policy_attachments = local.number_of_custom_policy_attachments
  custom_policy_arns                  = local.custom_policy_arns
  tags                                = merge(var.lambda_function_tags, var.default_tags)

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
  count = var.create_sns_topic ? 1 : 0

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

module "eventbridge_scheduler" {
  source = "../eventbridge-schedule"

  create_schedule_group = var.create_eventbridge_schedule_group
  schedule_group_name   = var.eventbridge_schedule_group_name

  create_schedule      = var.create_eventbridge_schedule
  schedule_name        = var.eventbridge_schedule_name
  schedule_expression  = var.eventbridge_schedule_expression
  flexible_time_window = var.eventbridge_flexible_time_window
  schedule_target = {
    target_arn = module.lambda_function.lambda_function_arn
    role_arn   = aws_iam_role.eventbridge_scheduler.0.arn
    input      = try(var.eventbridge_schedule_target_input, null) != null ? var.eventbridge_schedule_target_input : null
  }
  tags = merge(var.eventbridge_tags, var.default_tags)
}

resource "aws_iam_role" "eventbridge_scheduler" {
  count = var.create_eventbridge_schedule ? 1 : 0

  name = "eventbridge-scheduler-role-${random_id.id.hex}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "scheduler.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "eventbridge_scheduler_lambda_policy" {
  count = var.create_eventbridge_schedule ? 1 : 0

  name        = "eventbridge-scheduler-lambda-policy-${random_id.id.hex}"
  description = "IAM policy for the Lambda function to be invoked by the EventBridge scheduler"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "lambda:InvokeFunction"
        Resource = module.lambda_function.lambda_function_arn
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eventbridge_scheduler_lambda_policy_attachment" {
  count = var.create_eventbridge_schedule ? 1 : 0

  role       = aws_iam_role.eventbridge_scheduler.0.name
  policy_arn = aws_iam_policy.eventbridge_scheduler_lambda_policy.0.arn
}