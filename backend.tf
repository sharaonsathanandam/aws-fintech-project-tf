terraform {
  backend "s3" {
    bucket         = "fintech-tfstate-bucket"
    key            = "env/dev/terraform.tfstate"
    region         = "us-east-2"
    encrypt        = true
    use_lock_table = true
    dynamodb_table {
                    name = "terraform-locks"
                    }
  }
}