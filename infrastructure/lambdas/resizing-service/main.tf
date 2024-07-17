module "scale_up_ecs" {
  source = "../../modules/complete"

  create_lambda_function           = true
  lambda_function_name             = "scale-up-ecs-function"
  lambda_function_description      = "A Lambda function to scale up an ECS service"
  lambda_function_handler          = "lambda_function.lambda_handler"
  lambda_function_runtime          = "python3.8"
  lambda_function_timeout          = 120
  lambda_function_memory_size      = 128
  lambda_function_source_code_path = "../../../lambdas/resizing-service"
  lambda_function_custom_policy_arns = [
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/ecs-modify-policy",
  ]
  lambda_function_env = {
    "REGION"    = var.default_aws_region
    "LOG_LEVEL" = "INFO"
  }
  lambda_function_tags = {
    "Environment" = "PRD"
    "Team"        = "DevOps"
    "Project"     = "resizing-service"
  }

  create_sns_topic = false

  depends_on = [aws_iam_policy.ecs_modify_policy]
}

module "scale_down_ecs" {
  source = "../../modules/complete"

  create_lambda_function           = true
  lambda_function_name             = "scale-down-ecs-function"
  lambda_function_description      = "A Lambda function to scale down an ECS service"
  lambda_function_handler          = "lambda_function.lambda_handler"
  lambda_function_runtime          = "python3.8"
  lambda_function_timeout          = 120
  lambda_function_memory_size      = 128
  lambda_function_source_code_path = "../../../lambdas/resizing-service"
  lambda_function_custom_policy_arns = [
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/ecs-modify-policy",
  ]
  lambda_function_env = {
    "REGION"    = var.default_aws_region
    "LOG_LEVEL" = "INFO"
  }
  lambda_function_tags = {
    "Environment" = "PRD"
    "Team"        = "DevOps"
    "Project"     = "resizing-service"
  }

  create_sns_topic = false

  depends_on = [aws_iam_policy.ecs_modify_policy]
}

resource "aws_iam_policy" "ecs_modify_policy" {
  name        = "ecs-modify-policy"
  description = "IAM policy for the scale-up-ecs and scale-down-ecs Lambda functions"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecs:UpdateService",
          "ecs:DescribeServices",
          "ecs:ListServices",
        ]
        Resource = "*"
      },
    ]
  })
}