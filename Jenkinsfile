pipeline {
  agent any

  environment {
    AWS_DEFAULT_REGION = 'us-east-2'
  }

  stages {

    stage('Who Am I') {
      steps {
        sh 'aws sts get-caller-identity'
      }
    }

    stage('Terraform Init & Plan') {
      steps {
        sh '/usr/local/bin/terraform init'
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
