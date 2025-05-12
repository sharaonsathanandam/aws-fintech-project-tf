locals {
  dataset_name_final = var.dataset_name != "" ? var.dataset_name : var.bucket_name
}

#Create S3 buckets for the dataset
resource "aws_s3_bucket" "s3_bucket" {
  bucket        = var.bucket_name
  force_destroy = var.force_destroy
  tags          = {
                    Description  = "Landing bucket for ${local.dataset_name_final}"
                    Team         = var.team_name
                    Data_Classification = var.data_classification
                    Environment  = var.environment
                    Dataset      = local.dataset_name_final
                  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_bucket_kms" {
  bucket = aws_s3_bucket.s3_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_id
    }
  }
}

#Enable Versioning for tamper-evidence
resource "aws_s3_bucket_versioning" "s3_bucket_versioning" {
  bucket    = aws_s3_bucket.s3_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

#Create folders
resource "aws_s3_object" "folders" {
  for_each = toset(var.folder_prefixes)
  bucket = aws_s3_bucket.s3_bucket.id
  key    = "${each.key}/"
  storage_class = "STANDARD"
  content = ""
}

#Create partitions
resource "aws_s3_object" "partitions" {
  for_each = toset(var.partition_paths)
  bucket   = aws_s3_bucket.s3_bucket.id
  key      = "${each.value}/"
  content  = ""
}

resource "aws_lakeformation_resource" "data_lake" {
  arn                     = aws_s3_bucket.s3_bucket.arn
  use_service_linked_role = true
}

resource "aws_iam_role" "finance_analyst_role" {
  name = "FinanceAnalystAccessRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = "arn:aws:iam::${var.account_id}:saml-provider/AWSSSO"
      },
      Action = "sts:AssumeRoleWithSAML",
      Condition = {
        StringEquals = {
          "SAML:subType" = "group",
          "SAML:groupName" = "Finance-Analysts"
        }
      }
    }]
  })
}

resource "aws_lakeformation_lf_tag" "team" {
  key    = "Data_Classification"
  values = ["fin_analysis", "treas_ops"]
}
