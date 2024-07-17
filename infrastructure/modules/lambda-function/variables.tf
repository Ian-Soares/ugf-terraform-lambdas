variable "create" {
  description = "Whether to create the Lambda function"
  type        = bool
  default     = true
}

variable "name" {
  description = "The name of the Lambda function"
  type        = string
}

variable "description" {
  description = "The description of the Lambda function"
  type        = string
  default     = ""
}

variable "handler" {
  description = "The entry point of the Lambda function"
  type        = string
}

variable "runtime" {
  description = "The runtime of the Lambda function"
  type        = string
}

variable "timeout" {
  description = "The amount of time your Lambda function has to run in seconds"
  type        = number
  default     = 10
}

variable "memory_size" {
  description = "The amount of memory your Lambda function has access to in MB"
  type        = number
  default     = 128
}

variable "vpc_config" {
  description = "The VPC configuration of the Lambda function"
  type = object({
    subnet_ids         = list(string)
    security_group_ids = list(string)
  })
  default = null
}

variable "env" {
  description = "The environment variables of the Lambda function"
  type        = map(string)
  default     = {}
}

variable "source_code_path" {
  description = "The path to the source code of the Lambda function"
  type        = string
}

variable "output_path" {
  description = "The path to store the output of the Lambda function"
  type        = string
  default     = "./dist"
}

variable "custom_policy_arns" {
  description = "The ARNs of custom IAM policies to attach to the Lambda function"
  type        = list(string)
  default     = []
}

variable "number_of_custom_policy_attachments" {
  description = "The number of custom IAM policies to attach to the Lambda function"
  type        = number
  default     = 0
}

variable "tags" {
  description = "The tags of the Lambda function"
  type        = map(string)
  default     = {}
}