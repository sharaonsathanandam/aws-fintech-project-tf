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
  bucket_name   = "kraken-data-lake"
  force_destroy = true
  team_name = "Financial Analyst"
  data_classification = "restricted"
  environment = "dev"
  dataset_name = ""
  folder_prefixes = ["a","b","c"]
  partition_paths = ["year=2025", "month=05", "day=10"]
  kms_key_id = module.kms_key.key_arn
}