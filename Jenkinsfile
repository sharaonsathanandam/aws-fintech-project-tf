pipeline {
  agent any

  environment {
    AWS_DEFAULT_REGION = 'us-east-1'
  }

  stages {
    stage('Terraform Init & Plan') {
      steps {
        sh 'terraform init'
        sh 'terraform plan -out=tfplan'
      }
    }

    stage('Terraform Apply') {
      when {
        branch 'master'
      }
      steps {
        input "Approve Apply?"
        sh 'terraform apply tfplan'
      }
    }
  }
}
