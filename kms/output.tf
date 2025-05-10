output "key_arn" {
  value = aws_kms_key.kraken-kms-key.arn
}

output "key_id" {
  value = aws_kms_key.kraken-kms-key.key_id
}
