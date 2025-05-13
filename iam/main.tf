data "aws_caller_identity" "current" {}
# --- IAM Policy for fin_analysis Group (Read-Only on Tagged Buckets) ---

resource "aws_iam_policy" "fin_analysis_s3_policy" {
  name        = "FinAnalysisS3ReadOnlyTaggedAccess"
  description = "Allows read-only access to S3 buckets tagged with Data_Classification=fin_analysis"

  # Policy Document using heredoc syntax
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # Allows listing all buckets (needed for console/CLI visibility)
        # Access *into* buckets is controlled by the next statement
        Sid    = "AllowListAllBuckets"
        Effect = "Allow"
        Action = [
          "s3:ListAllMyBuckets",
          "s3:GetBucketLocation" # Often needed with ListAllMyBuckets
        ]
        Resource = "*" # Applies globally
      },
      {
        # Allows listing objects within buckets tagged correctly
        Sid    = "AllowListBucketIfCorrectTag"
        Effect = "Allow"
        Action = "s3:ListBucket"
        Resource = "arn:aws:s3:::*" # Applies to all buckets
        Condition = {
          StringEquals = {
            # Condition applies only if the bucket has the correct tag
            "s3:ResourceTag/Data_Classification" = "fin_analysis"
          }
        }
      },
      {
        # Allows reading objects within buckets tagged correctly
        Sid    = "AllowReadObjectsIfCorrectTag"
        Effect = "Allow"
        Action = "s3:GetObject"
        # Applies to all objects within all buckets
        Resource = "arn:aws:s3:::*/*"
        Condition = {
          StringEquals = {
            # Condition applies only if the bucket containing the object has the correct tag
            "s3:ResourceTag/Data_Classification" = "fin_analysis"
          }
        }
      }
    ]
  })
}

# --- IAM Policy for treas_ops Group (Read/Write on Tagged Buckets) ---

resource "aws_iam_policy" "treas_ops_s3_policy" {
  name        = "TreasOpsS3ReadWriteTaggedAccess"
  description = "Allows read/write access to S3 buckets tagged with Data_Classification=treas_ops"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # Allows listing all buckets (needed for console/CLI visibility)
        Sid    = "AllowListAllBuckets"
        Effect = "Allow"
        Action = [
          "s3:ListAllMyBuckets",
          "s3:GetBucketLocation"
        ]
        Resource = "*"
      },
      {
        # Allows reading on cloudtrail logs (needed for console/CLI visibility)
        Sid    = "AllowListCTLogs"
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetObject"
        ]
        Resource = ["arn:aws:s3:::ct-logs-default", "arn:aws:s3:::ct-logs-default/*"]
      },
      {
        # Allows listing objects within buckets tagged correctly
        Sid    = "AllowListBucketIfCorrectTag"
        Effect = "Allow"
        Action = "s3:ListBucket"
        Resource = "arn:aws:s3:::*"
        Condition = {
          StringEquals = {
            "s3:ResourceTag/Data_Classification" = "treas_ops"
          }
        }
      },
      {
        # Allows reading, writing, and deleting objects within buckets tagged correctly
        Sid    = "AllowReadWriteDeleteObjectsIfCorrectTag"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:PutObjectAcl"
        ]
        Resource = "arn:aws:s3:::*/*"
        Condition = {
          StringEquals = {
            "s3:ResourceTag/Data_Classification" = "treas_ops"
          }
        }
      },
      {
        # Allows reading, writing, and deleting objects within buckets tagged correctly
        Sid    = "AllowReadCloudWatchLogs"
        Effect = "Allow"
        Action = [
          "logs:FilterLogEvents",
          "logs:GetLogEvents",
          "logs:DescribeLogStreams",
          "logs:DescribeLogGroups" # Often needed for writes depending on use case
        ]
        Resource = "arn:aws:logs:us-east-2:${data.aws_caller_identity.current.account_id}:log-group:*"
      }
    ]
  })
}

# # --- Attach Policies to Groups ---
#
# resource "aws_iam_group_policy_attachment" "fin_analysis_s3_attach" {
#   group      = aws_iam_group.fin_analysis.name
#   policy_arn = aws_iam_policy.fin_analysis_s3_policy.arn
# }
#
# resource "aws_iam_group_policy_attachment" "treas_ops_s3_attach" {
#   group      = aws_iam_group.treas_ops.name
#   policy_arn = aws_iam_policy.treas_ops_s3_policy.arn
# }