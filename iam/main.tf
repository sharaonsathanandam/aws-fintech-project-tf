resource "aws_s3_bucket_policy" "cloudtrail_bucket_policy" {
  bucket = "kraken-data-lake-1"

  policy = data.aws_iam_policy_document.cloudtrail_s3_policy.json
}

data "aws_iam_policy_document" "cloudtrail_s3_policy" {
  statement {
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = [
      "s3:GetBucketAcl",
      "s3:PutObject"
    ]

    resources = [
      aws_s3_bucket.s3_bucket.arn,
      "${aws_s3_bucket.s3_bucket.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
    ]

    conditions {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}

data "aws_caller_identity" "current" {}