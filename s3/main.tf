# locals {
#   dataset_name_final = var.dataset_name != "" ? var.dataset_name : var.bucket_name
# }

#Create S3 buckets for the dataset
resource "aws_s3_bucket" "s3_bucket" {
  bucket        = var.bucket_name
  force_destroy = var.force_destroy
  retention_period = var.retention_period
  storage_class = "STANDARD"
  tags          = {
                    Description  = "Landing bucket for var.dataset_name"
                    Team         = var.team_name
                    Classification = var.data_classification
                    Environment  = var.environment
                    Dataset      = var.dataset_name
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
  key    = "${each.key}/"  # S3 folders are simulated with trailing slash
  content = ""
}

#Create partitions
resource "aws_s3_object" "partitions" {
  for_each = toset(var.partition_paths)
  bucket   = aws_s3_bucket.s3_bucket.id
  key      = "${each.value}/"
  content  = ""
}