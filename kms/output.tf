output "key_arn" {
  value = aws_kms_key.kms-key.arn
}

output "key_id" {
  value = aws_kms_key.kms-key.key_id
}
