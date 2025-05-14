variable "glue_scripts_bucket" {
  description = "Bucket to hold Glue scripts"
  type        = string
  default     = ""
}

variable "glue_job_name" {
  description = "Name of the Glue job for data quality checks"
  type        = string
  default     = ""
}

variable "glue_script" {
  description = "Name of the script for Glue job"
  type        = string
  default     = ""
}

variable "script_bucket" {
  description = "Name of the bucket which has Glue job"
  type        = string
  default     = "fintech-glue-scripts"
}

