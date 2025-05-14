module "kms_key" {
  source              = "./kms"
  description         = "My app key"
  alias_name          = "myapp-key"
  enable_key_rotation = true
  tags = {
    Environment = "dev"
    Owner       = "fintech"
  }
}

module "iam" {
  source = "./iam"
  glue_job_arn = module.glue_job.job_arn
}

module "data_lake_bucket" {
  source        = "./s3"
  bucket_name   = "fintech-data-lake-1"
  force_destroy = true
  team_name = "Financial Analyst"
  data_classification = "fin_analysis"
  environment = "Dev"
  kms_key_id = module.kms_key.key_arn
}

module "glue_scripts_bucket" {
  source        = "./s3"
  bucket_name   = "fintech-glue-scripts"
  force_destroy = true
  team_name = "Fintech"
  data_classification = "general"
  environment = "Dev"
  kms_key_id = module.kms_key.key_arn
}

module "sso-role-permissions" {
  source = "./sso-permissions"
}

module "cloudtrail" {
  source = "./cloudtrail"
  kms_key_id = module.kms_key.key_arn
}

module "glue_job" {
  source = "./glue"
  glue_job_name = "dq_checks"
}


module "sns_topic" {
  source = "./sns"
  sns_topic_name = "dq_alerts"
}

module "cloudwatch" {
  source = "./cloudwatch"
  sns_topic_name = "dq_alerts"
}

# module "eventbridge" {
#   source = "./eventbridge"
#   bucket_name = "fintech-data-lake-2"
#   glue_job_arn = module.glue_job.job_arn
#   glue_job_name = "dq_checks"
# }