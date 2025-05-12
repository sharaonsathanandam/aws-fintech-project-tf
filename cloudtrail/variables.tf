variable "kms_key_id"   {
  type = string
}
variable "log_retention_days" {
  type = number
  default = 365
}    # S3 lifecycle