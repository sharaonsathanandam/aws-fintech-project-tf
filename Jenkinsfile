pipeline {
  agent any

  environment {
    AWS_DEFAULT_REGION = 'us-east-2'
  }

  stages {

    stage('Who Am I') {
      steps {
        withCredentials([[
          $class: 'AmazonWebServicesCredentialsBinding',
          credentialsId: 'Terraform-CICD'
            ]]) {
            sh '/usr/local/bin/aws sts get-caller-identity'
        }
      }
    }

    stage('Terraform Init & Plan') {
      steps {
        withCredentials([[
          $class: 'AmazonWebServicesCredentialsBinding',
          credentialsId: 'Terraform-CICD'
            ]]) {
                sh '/usr/local/bin/terraform init'
                sh 'chmod +x .terraform/providers/**/terraform-provider-aws*'
                sh '/usr/local/bin/terraform plan -out=tfplan'
            }
      }
    }

    stage('Terraform Apply') {
      when {
        branch 'master'
      }
      steps {
        withCredentials([[
          $class: 'AmazonWebServicesCredentialsBinding',
          credentialsId: 'Terraform-CICD'
            ]]) {
                input "Approve Apply?"
                sh '/usr/local/bin/terraform apply tfplan'
            }
      }
    }
  }
}
