pipeline {
  agent any

  environment {
    AWS_DEFAULT_REGION = 'us-east-2'
    AWS_ACCESS_KEY_ID     = credentials('Terraform-CICD')
    AWS_SECRET_ACCESS_KEY = credentials('Terraform-CICD')
  }

  stages {

    stage('Terraform Init & Plan') {
      steps {
            sh '/usr/local/bin/terraform init'
            sh '''
                  echo "Removing quarantine flags recursively..."
                  find .terraform -type f -exec xattr -d com.apple.quarantine {} + 2>/dev/null || true

                  echo "Fixing execute permissions for provider binaries..."
                  find .terraform/providers -type f -name "terraform-provider-aws*" -exec chmod +x {} +
                '''
            sh '''
                  echo "Testing provider plugin manually..."
                  ls -l .terraform/providers/**/terraform-provider-aws*
                  file .terraform/providers/**/terraform-provider-aws*
                '''
            sh '/usr/local/bin/terraform plan -out=tfplan'
            }
     }

    stage('Terraform Apply') {
      when {
             branch 'master'
           }
      steps {
                input "Approve Apply?"
                sh '/usr/local/bin/terraform apply tfplan'
            }
      }
  }
}
