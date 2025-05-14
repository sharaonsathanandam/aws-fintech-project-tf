variable "glue_scripts_bucket" {
  description = "Bucket to hold Glue scripts"
  type        = string
  default     = "kraken-infra-glue-scripts"
}

variable "glue_job_name" {
  description = "Name of the Glue job for data quality checks"
  type        = string
  default     = "kraken_data_quality_checks"
}