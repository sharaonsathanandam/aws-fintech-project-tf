variable "bucket_name" {
  description = "Base name for the bucket"
  type        = string
}

variable "force_destroy" {
  description = "Force delete even if objects exist"
  type        = bool
  default     = false
}

variable "environment" {
  description = "The environment name for the bucket - dev/test/uat/prod"
  type        = string
  validation {
    condition     = contains(["dev", "test", "uat", "prod"], lower(var.environment))
    error_message = "Classification must be one of: Dev, Test, UAT, Prod."
  }
}

variable "enable_partitioning" {
  description = "Whether to create partitioned folders (like year/month/day)"
  type        = bool
  default     = true
}

variable "dataset_name" {
  description = "Name of the dataset (e.g., treasury_movements)"
  type        = string
  # validation {
  #   condition     = can(regex("^[a-z0-9_]+$", var.dataset_name))
  #   error_message = "Dataset name must be lowercase alphanumeric characters or underscores."
  # }
  default = ""
}

variable "folder_prefixes" {
  description = "List of folders to create inside the bucket"
  type        = list(string)
  default     = []
}

variable "team_name" {
  description = "Name of the team owning this dataset"
  type        = string
}

variable "data_classification" {
  description = "Sensitivity classification of the data"
  type        = string
  validation {
    condition     = contains(["fin_analysis", "treas_ops"], var.data_classification)
    error_message = "Classification must be one of: fin_analysis or treas_ops."
  }
}

variable "kms_key_id" {
  description = "KMS Key ID for encryption"
  type = string
}

variable "partition_paths" {
  description = "List of full partition paths to create"
  type        = list(string)
  default     = []
}


variable "retention_period" {
  description = "Data retention period in days"
  type        = number
  default     = 30
}

variable "expected_frequency" {
  description = "Expected data update frequency (e.g., daily, hourly)"
  type        = string
  default     = "daily"
}

variable "schema_definition" {
  description = "JSON schema definition of the dataset"
  type        = string
  default     = null
}

variable "account_id" {
  description = "Data retention period in days"
  type        = number
  default     = 632234552152
}
