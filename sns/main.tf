resource "aws_sns_topic" "data_quality_alerts" {
  name = var.sns_topic_name
}

resource "aws_sns_topic_subscription" "email_alerts" {
  topic_arn = aws_sns_topic.data_quality_alerts.arn
  protocol  = "email"
  endpoint  = "sharaonsathanandam@gmail.com"
}