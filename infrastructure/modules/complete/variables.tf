variable "default_tags" {
  description = "The default tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "create_lambda_function" {
  description = "Whether to create the Lambda function"
  type        = bool
  default     = true
}

variable "lambda_function_name" {
  description = "The name of the Lambda function"
  type        = string
}

variable "lambda_function_description" {
  description = "The description of the Lambda function"
  type        = string
}

variable "lambda_function_handler" {
  description = "The handler function of the Lambda function"
  type        = string
}

variable "lambda_function_runtime" {
  description = "The runtime of the Lambda function"
  type        = string
}

variable "lambda_function_timeout" {
  description = "The timeout of the Lambda function"
  type        = number
}

variable "lambda_function_source_code_path" {
  description = "The path to the source code of the Lambda function"
  type        = string
}

variable "lambda_vpc_config" {
  description = "The VPC configuration of the Lambda function"
  type = object({
    subnet_ids         = list(string)
    security_group_ids = list(string)
  })
  default = null
}

variable "lambda_function_env" {
  description = "The environment variables for the Lambda function"
  type        = map(string)
}

variable "lambda_function_custom_policy_arns" {
  description = "The ARNs of custom policies to attach to the Lambda function"
  type        = list(string)
  default     = []
}

variable "lambda_function_tags" {
  description = "The tags to apply to the Lambda function"
  type        = map(string)
}

variable "create_sns_topic" {
  description = "Whether to create the SNS topic"
  type        = bool
  default     = true
}

variable "sns_topic_name" {
  description = "The name of the SNS topic"
  type        = string
}

variable "sns_topic_subscriptions" {
  description = "The subscriptions for the SNS topic"
  type = list(object({
    protocol = string
    endpoint = string
  }))
  default = []
}

variable "sns_topic_tags" {
  description = "The tags to apply to the SNS topic"
  type        = map(string)
  default     = {}
}