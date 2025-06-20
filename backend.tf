terraform {
  backend "s3" {
    bucket         = "fintech-tfstate-bucket"
    key            = "env/dev/terraform.tfstate"
    region         = "us-east-2"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}