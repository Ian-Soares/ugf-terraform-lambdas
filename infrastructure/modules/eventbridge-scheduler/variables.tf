variable "create_schedule_group" {
  description = "Whether to create the schedule group"
  type        = bool
  default     = false
}

variable "schedule_group_name" {
  description = "Default name for the schedule group"
  type        = string
  default     = "default"
}

variable "create_schedule" {
  description = "Whether to create the schedule"
  type        = bool
  default     = true
}

variable "schedule_name" {
  description = "Name of the schedule"
  type        = string
}

variable "flexible_time_window" {
  description = "The flexible time window"
  type = object({
    maximum_window_in_minutes = optional(number, null)
    mode                      = optional(string, null)
  })
  default = {
    maximum_window_in_minutes = null
    mode                      = "OFF"
  }
}

variable "schedule_expression" {
  description = "The schedule expression"
  type        = string
  default     = "rate(1 hours)"
}

variable "schedule_target" {
  description = "The target for the schedule"
  type = object({
    target_arn = string
    role_arn   = string
    input      = optional(string, null)
  })
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}