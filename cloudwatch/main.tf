data "aws_sns_topic" "data_quality_alerts" {
  name = var.sns_topic_name
}

#Cloudwatch alarm for duplication rate
resource "aws_cloudwatch_metric_alarm" "dup_rate_alarm" {
  alarm_name          = "HighDuplicationRate"
  namespace           = "DataQuality"
  metric_name         = "DuplicationRate"
  threshold           = 1.0
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  period              = 300
  alarm_actions       = [data.aws_sns_topic.data_quality_alerts.arn]
  ok_actions          = [data.aws_sns_topic.data_quality_alerts.arn]
}