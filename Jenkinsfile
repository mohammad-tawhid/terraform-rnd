pipeline {
    agent any
    tools {
       terraform 'terraform'
    }
    environment {
        AWS_ACCESS_KEY_ID     = credentials('mn_iam_aws_access_key')
        AWS_SECRET_ACCESS_KEY = credentials('mn_iam_aws_secret_key')
    }
    stages {
        stage('Git checkout') {
           steps{
                git branch: 'main', url: 'https://github.com/mohammad-tawhid/terraform-rnd'
            }
        }
        stage('terraform Init') {
            steps{
                sh 'terraform init -force-copy'
            }
        }
        stage('terraform Plan') {
            steps{
                sh 'terraform plan'
            } 
        }
        stage ('Approve Plan and continue to Apply') {
            steps{
            timeout(time: 3600, unit: 'SECONDS') {
                input 'Do you want to proceed apply?'
               }
            }
        }        
        stage('terraform apply') {
            steps{
                sh 'terraform apply --auto-approve'
            }
        }
        // stage('CleanWorkspace') {
        //     steps{
        //         cleanWs()
        //     }
        // }
      }
    }
