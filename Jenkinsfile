pipeline {
    agent any
    
    environment {
        AWS_REGION = 'eu-north-1'             
        TF_VAR_aws_region = AWS_REGION
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Create Infrastructure') {
            steps {
                script {
                    sh 'terraform init'
                    sh 'terraform plan'
                    sh 'terraform apply -auto-approve'
                }
            }
        }

        stage('Deploy Applications') {
            steps {
                script {
                    sh './backend.sh'
                    sh './frontend.sh'
                }
            }
        }

        stage('Test Solution') {
            steps {
                script {
                    
                }
            }
        }
    }

    post {
        always {
           
            echo 'Cleaning up...'
            sh 'terraform destroy -auto-approve'
        }
    }
}

