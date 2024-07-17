output "lambda_function_arn" {
  value = module.lambda_function.lambda_function_arn
}

output "sns_topic_arn" {
  value = module.sns_topic.topic_arn
}