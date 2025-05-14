data "aws_iam_role" "iam_glue_job_role" {
  # Specify the name of the existing IAM role you want to look up
  name = "glue-job-role"
}

resource "aws_glue_job" "data_quality_checks" {
  name     = var.glue_job_name
  role_arn = "${data.aws_iam_role.iam_glue_job_role.arn}"

  command {
    name            = "glueetl"
    python_version  = "3"
    script_location = "s3://${var.script_bucket}/${var.glue_script}"
  }

  default_arguments = {
    "--TempDir"                = "s3://${var.script_bucket}/temp/"
    "--job-bookmark-option"    = "job-bookmark-enable"
  }

  glue_version      = "3.0"
  number_of_workers = 5
  worker_type       = "G.1X"
  max_retries       = 1
}

output "job_arn" {
  value = aws_glue_job.data_quality_checks.arn
}