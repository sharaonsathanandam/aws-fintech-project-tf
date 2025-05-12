variable "log_bucket_name"   { type = string  default = "company-cloudtrail-logs" }
variable "data_bucket_name"  { type = string  default = "kraken-data-lake-1" }

variable "kms_key_id"        { type = string    }   # encrypt log files
variable "log_retention_days"{ type = number  default = 365 }    # S3 lifecycle