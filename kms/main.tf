resource "aws_kms_key" "cloudtrail_key" {
  description             = "KMS key for CloudTrail logs encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "Enable IAM User Permissions",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::632234552152:root"
        },
        Action   = "kms:*",
        Resource = "*"
      },
      {
        Sid    = "Allow CloudTrail to encrypt logs",
        Effect = "Allow",
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        },
        Action = [
          "kms:GenerateDataKey*",
          "kms:Decrypt"
        ],
        Resource = "*",
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = "632234552152"
          },
          StringLike = {
            "aws:SourceArn" = "arn:aws:cloudtrail:*:632234552152:trail/*"
          }
        }
      }
    ]
  })
}

resource "aws_kms_alias" "cloudtrail_key_alias" {
  name          = "alias/cloudtrail-key"
  target_key_id = aws_kms_key.cloudtrail_key.key_id
}