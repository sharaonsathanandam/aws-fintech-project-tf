terraform {
  backend "s3" {
    bucket         = "fintech-tfstate-bucket"
    key            = "env/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
