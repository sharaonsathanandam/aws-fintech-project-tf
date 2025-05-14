data "aws_caller_identity" "current" {}

data "aws_s3_bucket" "glue_script_bucket" {
  bucket = "fintech-glue-scripts"
}

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
          "s3:GetBucketLocation"
        ]
        Resource = "*"
      },
      {
        # Allows listing objects within buckets tagged correctly
        Sid    = "AllowListBucketIfCorrectTag"
        Effect = "Allow"
        Action = "s3:ListBucket"
        Resource = "arn:aws:s3:::*"
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

#IAM Policy for Glue Job
resource "aws_iam_role" "iam_glue_job_role" {
  name = "glue-job-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "glue.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "glue_job_policy" {
  name        = "GlueJobDataQualityPolicy"
  description = "Permissions for Glue job to read raw, write curated, and emit metrics"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      // S3 read raw
      {
        Effect   = "Allow",
        Action   = ["s3:GetObject","s3:ListBucket"],
        Resource = [
          "arn:aws:s3:::*/raw",
          "arn:aws:s3:::*/raw/*"
        ]
      },
      // S3 write curated
      {
        Effect   = "Allow",
        Action   = ["s3:PutObject"],
        Resource = "arn:aws:s3:::*/curated/*"
      },
      // CloudWatch metrics
      {
        Effect   = "Allow",
        Action   = ["cloudwatch:PutMetricData"],
        Resource = "*"
      },
      // Glue catalog read if needed
      {
        Effect   = "Allow",
        Action   = ["glue:GetTable","glue:GetDatabase"],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "glue_service_attach" {
  role       = aws_iam_role.iam_glue_job_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy_attachment" "glue_job_inline_attach" {
  role       = aws_iam_role.iam_glue_job_role.name
  policy_arn = aws_iam_policy.glue_job_policy.arn
}

resource "aws_iam_role" "eb_to_glue_workflow_role" {
  name = "eb-to-glue-workflow-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "events.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "eb_to_glue_workflow_policy" {
  name = "AllowEBStartGlueWorkflow"
  role = aws_iam_role.eb_to_glue_workflow_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = ["glue:StartWorkflowRun"],
      Resource = [
        "arn:aws:glue:us-east-2:${data.aws_caller_identity.current.account_id}:workflow/*"
      ]
    }]
  })
}