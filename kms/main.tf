resource "aws_kms_key" "kms-key" {
  description         = var.description
  enable_key_rotation = var.enable_key_rotation
  is_enabled          = true
  policy = var.policy != null ? var.policy : null
  tags = var.tags
}

resource "aws_kms_alias" "kms-alias" {
  count         = var.alias_name != null ? 1 : 0
  name          = "alias/${var.alias_name}"
  target_key_id = aws_kms_key.kms-key.key_id
}
