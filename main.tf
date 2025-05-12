module "kms_key" {
  source              = "./kms"
  description         = "My app key"
  alias_name          = "myapp-key"
  enable_key_rotation = true
  tags = {
    Environment = "dev"
    Owner       = "Kraken"
  }
}

module "s3_bucket" {
  source        = "./s3"
  bucket_name   = "kraken-data-lake-1"
  force_destroy = true
  team_name = "Financial Analyst"
  data_classification = "fin_analysis"
  environment = "Dev"
  kms_key_id = module.kms_key.key_arn
}

module "sso-role-permissions" {
  source = "./sso-permissions"
}

module "iam" {
  source = "./iam"
}

module "cloudtrail" {
  source = "./cloudtrail"
  kms_key_id = module.kms_key.key_arn
}