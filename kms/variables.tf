variable "description" {
  type        = string
  description = "Description for the KMS key"
}

variable "enable_key_rotation" {
  type        = bool
  default     = true
  description = "Enable key rotation"
}

variable "alias_name" {
  type        = string
  default     = null
  description = "Alias name for the key (without 'alias/' prefix)"
}

variable "policy" {
  type        = string
  default     = null
  description = "Optional key policy. If not set, AWS default policy is used"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to assign to the key"
}
