data "aws_caller_identity" "current" {}

data "aws_iam_role" "eb_to_glue_role" {
  name = "eb-to-glue-workflow-role"
}

#Eventbridge rules
resource "aws_cloudwatch_event_rule" "on_new_data" {
  name = "OnNewData"
  event_pattern = jsonencode({
    source       = ["aws.s3"],
    "detail-type" = ["Object Created"],
    detail = {
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
  arn      = "arn:aws:glue:us-east-2:${data.aws_caller_identity.current.account_id}:workflow/${var.glue_job_name}"
  role_arn  = data.aws_iam_role.eb_to_glue_role.arn
  input     = jsonencode({ JobName = var.glue_job_name })
}