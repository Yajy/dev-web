pipeline {
    agent any
    environment {
        TERRAFORM_DIR = 'terraform'
        AWS_CREDENTIALS_ID = 'aws-credentials' 
        SSH_KEY_PATH = '/home/yajy/web-dev-keyPair.pem'
    }
    stages {
        stage('Create_Infra') {
            steps {
                dir(TERRAFORM_DIR) {
                    withAWS(credentials: "${AWS_CREDENTIALS_ID}", region: 'eu-north-1') {
                        script {
                   
                            sh 'terraform init'
                            
                            sh 'terraform apply -auto-approve'
                        }
                    }
                }
            }
        }

        stage('Deploy_Apps') {
            steps {
                dir(TERRAFORM_DIR) {
                    withAWS(credentials: "${AWS_CREDENTIALS_ID}", region: 'eu-north-1') {
                        script {
                            sh 'terraform apply -auto-approve'
                        }
                    }
                }
                
                script {
                    def frontend_ip = sh(script: 'terraform output -raw frontend_public_ip', returnStdout: true).trim()
                    sh """
                        ssh -o StrictHostKeyChecking=no -i /path/to/your/key.pem ubuntu@${frontend_ip} 'bash /tmp/frontend.sh'
                    """
                }
                
                script {
                    def backend_ip = sh(script: 'terraform output -raw backend_private_ip', returnStdout: true).trim()
                    sh """
                        ssh -o StrictHostKeyChecking=no -i /path/to/your/key.pem ubuntu@${backend_ip} 'bash /tmp/backend.sh'
                    """
                }
            }
        }

        stage('Test_Solution') {
            steps {
                script {
                    def frontend_ip = sh(script: 'terraform output -raw frontend_public_ip', returnStdout: true).trim()
                    
                    echo "Frontend Public IP: ${frontend_ip}"
  
                    sh "curl -I http://${frontend_ip}"
                }
            }
        }
    }
    post {
        always {
            dir(TERRAFORM_DIR) {
                withAWS(credentials: "${AWS_CREDENTIALS_ID}", region: 'eu-north-1') {
                    sh 'terraform destroy -auto-approve'
                }
            }
        }
    }
}
