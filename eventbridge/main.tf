resource "aws_cloudwatch_event_rule" "on_new_data" {
  name = "OnNewData"
  event_pattern = jsonencode({
    source       = ["aws.s3"],
    "detail-type" = ["Object Created"],
    detail = {
      bucket = { name = [var.bucket_name] },
      object = { key = [
        { suffix = ".parquet" },
        { suffix = ".csv"     },
        { suffix = ".avro"    }
      ] }
    }
  })
}

resource "aws_cloudwatch_event_target" "trigger_glue" {
  rule      = aws_cloudwatch_event_rule.on_new_data.name
  arn       = aws_glue_job.data_quality_checks.arn
  role_arn  = aws_iam_role.eb_to_glue_role.arn
  input     = jsonencode({ JobName = aws_glue_job.data_quality_checks.name })
}