#Create S3 bucket for store logs
resource "aws_s3_bucket" "trail_logs" {
  bucket = "ct-logs-default"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "trail" {
  bucket = aws_s3_bucket.trail_logs.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_id
    }
  }
}


#lifecycle – transition to Glacier then delete
resource "aws_s3_bucket_lifecycle_configuration" "trail" {
  bucket = aws_s3_bucket.trail_logs.id
  rule {
    id      = "retention"
    status  = "Enabled"
    expiration { days = var.log_retention_days }
  }
}

resource "aws_cloudtrail" "main" {
  name                          = "lake-formation-audit-trail"
  s3_bucket_name                = aws_s3_bucket.trail_logs.id
  kms_key_id                    = var.kms_key_id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_logging                = true
  event_selector {
    read_write_type           = "All"
    include_management_events = true
}
}

data "aws_iam_policy_document" "trail_bucket" {
  # 1. ACL check
  statement {
    sid     = "AWSCloudTrailAclCheck"
    effect  = "Allow"
    actions = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.trail_logs.arn]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }

  # 2.PutObject
  statement {
    sid     = "AWSCloudTrailWrite"
    effect  = "Allow"
    actions = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.trail_logs.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

resource "aws_s3_bucket_policy" "trail" {
  bucket = aws_s3_bucket.trail_logs.id
  policy = data.aws_iam_policy_document.trail_bucket.json
}

# management & S3 data‑events for the lake bucket
resource "aws_cloudtrail_event_selector" "all_data" {
  name = aws_cloudtrail.main.name
  # management (Console, IAM, etc.) – read+write
  read_write_type = "All"
  include_management_events = true
}

###############################################################################
# helpers
###############################################################################
data "aws_caller_identity" "current" {}
