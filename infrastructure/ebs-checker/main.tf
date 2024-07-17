module "complete" {
  source = "../modules/complete"

  create_lambda_function           = true
  lambda_function_name             = "ebs-checker-function"
  lambda_function_description      = "A Lambda function to check if EBS volumes are using GP3 storage"
  lambda_function_handler          = "lambda_function.lambda_handler"
  lambda_function_runtime          = "python3.8"
  lambda_function_timeout          = 120
  lambda_function_memory_size      = 1028
  lambda_function_source_code_path = "../../lambdas/ebs-checker"
  lambda_function_custom_policy_arns = [
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/ebs-modify-policy",
  ]
  lambda_function_env = {
    "REGION"      = var.default_aws_region
    "LOG_LEVEL"   = "INFO"
    "MODIFY_EBS"  = true
    SNS_TOPIC_ARN = module.complete.sns_topic_arn
  }
  lambda_function_tags = {
    "Environment" = "PRD"
    "Team"        = "DevOps"
    "Project"     = "ebs-checker"
  }

  create_sns_topic = true
  sns_topic_name   = "ebs-checker-topic"
  sns_topic_subscriptions = [
    {
      protocol = "email"
      endpoint = "ian.soares@selectsolucoes.com"
    }
  ]

  depends_on = [aws_iam_policy.ebs_modify_policy]
}

resource "aws_iam_policy" "ebs_modify_policy" {
  name        = "ebs-modify-policy"
  description = "IAM policy for the ebs-checker Lambda function"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeVolumes",
          "ec2:ModifyVolume",
        ]
        Resource = "*"
      },
    ]
  })
}