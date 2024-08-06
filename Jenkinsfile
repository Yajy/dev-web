pipeline {
    agent any
    environment {
        TERRAFORM_DIR = 'terraform'
    }
    stages {
        stage('Create_Infra') {
            steps {
                dir(TERRAFORM_DIR) {
                    script {
                    
                        sh 'terraform init'
                        
                        sh 'terraform apply -auto-approve'
                    }
                }
            }
        }

        stage('Deploy_Apps') {
            steps {
                dir(TERRAFORM_DIR) {
                    script {
                   
                        sh 'terraform apply -auto-approve'
                    }
                }
              
                script {
                    def frontend_ip = sh(script: 'terraform output -raw frontend_public_ip', returnStdout: true).trim()
                    sh """
                        ssh -o StrictHostKeyChecking=no -i /path/to/your/key.pem ec2-user@${frontend_ip} 'bash /tmp/frontend.sh'
                    """
                }
                
              
                script {
                    def backend_ip = sh(script: 'terraform output -raw backend_private_ip', returnStdout: true).trim()
                    sh """
                        ssh -o StrictHostKeyChecking=no -i /path/to/your/key.pem ec2-user@${backend_ip} 'bash /tmp/backend.sh'
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
                sh 'terraform destroy -auto-approve'
            }
        }
    }
}
