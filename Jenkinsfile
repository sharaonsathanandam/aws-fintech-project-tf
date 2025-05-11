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
            sh '/usr/local/bin/terraform init -reconfigure'
            sh '/usr/local/bin/terraform plan -out=tfplan'
            }
     }

    stage('Terraform Apply') {
      when {
             branch 'master'
           }
      steps {
                input "Approve Apply?"
                sh 'gtimeout 600 /usr/local/bin/terraform apply tfplan'
            }
      }
  }
}
