resource "aws_scheduler_schedule_group" "group" {
  count = var.create_schedule_group ? 1 : 0

  name = var.schedule_group_name
  tags = var.tags
}

resource "aws_scheduler_schedule" "this" {
  count = var.create_schedule ? 1 : 0

  name       = var.schedule_name
  group_name = aws_scheduler_schedule_group.group.0.name

  flexible_time_window {
    maximum_window_in_minutes = var.flexible_time_window.maximum_window_in_minutes
    mode                      = var.flexible_time_window.mode
  }

  schedule_expression = var.schedule_expression

  target {
    arn      = var.schedule_target.target_arn
    role_arn = var.schedule_target.role_arn
  }
}