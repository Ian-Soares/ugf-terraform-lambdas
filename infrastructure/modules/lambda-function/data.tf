data "archive_file" "lambda_source_code" {
  type        = "zip"
  source_dir  = var.source_code_path
  output_path = "${var.output_path}/${var.name}.zip"
}