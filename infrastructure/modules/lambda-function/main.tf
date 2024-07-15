resource "aws_lambda_function" "this" {
  count = var.create ? 1 : 0

  function_name    = var.name
  description      = var.description
  handler          = var.handler
  runtime          = var.runtime
  role             = aws_iam_role.iam_role.arn
  timeout          = var.timeout
  memory_size      = var.memory_size
  filename         = data.archive_file.lambda_source_code.output_path
  source_code_hash = data.archive_file.lambda_source_code.output_base64sha256

  dynamic "vpc_config" {
    for_each = var.vpc_config != null ? [1] : []

    content {
      subnet_ids         = var.vpc_config.subnet_ids
      security_group_ids = var.vpc_config.security_group_ids
    }
  }
  environment {
    variables = var.env
  }

  tags = var.tags
}

resource "aws_iam_role" "iam_role" {
  name = "${var.name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      },
    ]
  })
}

resource "aws_iam_policy" "iam_policy" {
  name        = "${var.name}-policy"
  description = "IAM policy for the ${var.name} Lambda function"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "iam_role_policy_attachment" {
  role       = aws_iam_role.iam_role.name
  policy_arn = aws_iam_policy.iam_policy.arn
}

resource "aws_iam_role_policy_attachment" "custom_policy_attachments" {
  count = length(var.custom_policy_arns)

  role       = aws_iam_role.iam_role.name
  policy_arn = var.custom_policy_arns[count.index]
}