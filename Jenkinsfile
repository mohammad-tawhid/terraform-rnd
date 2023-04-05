pipeline {
    agent any
    tools {
       terraform 'terraform'
    }
    environment {
        //AWS_ACCESS_KEY_ID     = credentials('aws_access_key')
        //AWS_SECRET_ACCESS_KEY = credentials('aws_secret_key')
        AWS_DEFAULT_REGION = ap-southeast-1
    }

    parameters {
        // string(defaultValue: "develop", description: 'Select branch for bapp-infra:', name: 'IBRANCH')
        choice(choices: ['uat' , 'lt', 'prod'], description: 'Select Environment', name: 'ENVIRONMENT')
        string(defaultValue: "develop", description: 'MW Release Tag:', name: 'MWRELEASETAG')

        choice( name: 'auth', choices: "No\nYes", description: 'Deploy App auth Module?' )
        choice( name: 'login', choices: "No\nYes", description: 'Deploy login Module?' )
        
    }    

    stages {
        stage ('WarmUP') {
            parallel {
                stage('Checkout Infra Code') {
                    steps {
                        script {
                            if (env.ENVIRONMENT == 'prod') {
                                IBRANCH = 'main'
                            }
                            if (env.ENVIRONMENT == 'uat') {
                                IBRANCH = 'develop'
                        }
                        git(url: "https://github.com/mohammad-tawhid/terraform-rnd", branch: "${IBRANCH}")
                    }
                }
            }
        } 
        }           
        // stage('Git checkout') {
        //    steps{
        //         git branch: 'rnd', url: 'https://github.com/mohammad-tawhid/terraform-rnd'
        //     }
        // }
        // stage('packer build') {
        //     steps{
        //         sh 'packer build ./image_build/'
        //     }
        // }       
        stage('AMI Build') {
            matrix {
                axes {
                    axis {
                        name 'MODULES'
                        values "auth", "login"
                    }
                }
                stages {
                    stage('Build ${MODULES} AMI') {
                        when { expression { params["${MODULES}"] == "Yes" } }
                        steps {
                            dir("packer") {
                                sh 'packer build ./image_build/'
                            }
                        }
                    }
                }
            }
        }

        stage('terraform Init') {
            steps{
                sh 'terraform init'
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
        // ok }
      }
    }
