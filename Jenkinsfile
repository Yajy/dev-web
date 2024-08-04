pipeline {
    agent any

    environment {
        SSH_KEY = credentials('my-ssh-key') 
        
        AWS_ACCESS_KEY_ID = credentials('aws_access_key_id')
        AWS_SECRET_ACCESS_KEY = credentials('aws_secret_access_key')
    }

    stages {
        stage('Create_Infra') {
            steps {
                script {
                    
                    dir('terraform') {
                        
                       sh '''
                        terraform init
                        terraform apply -auto-approve \
                        -var "aws_access_key=${AWS_ACCESS_KEY_ID}" \
                        -var "aws_secret_key=${AWS_SECRET_ACCESS_KEY}"
                    '''
                    }
                }
            }
        }

        stage('Deploy_Apps') {
            steps {
                script {
                    
                    def frontendPublicIp = sh(script: 'terraform output -raw frontend_public_ip', returnStdout: true).trim()
                    def backendPrivateIp = sh(script: 'terraform output -raw backend_private_ip', returnStdout: true).trim()

                    
                    sh '''
                        ssh -i "${SSH_KEY}" ec2-user@${frontendPublicIp} "cd /path/to/frontend && ./frontend.sh"
                    '''

                    
                    sh '''
                        ssh -i "${SSH_KEY}" ec2-user@${backendPrivateIp} "cd /path/to/backend && ./backend.sh"
                    '''
                }
            }
        }

        stage('Test_Solution') {
            steps {
                script {
                  
                    def frontendPublicIp = sh(script: 'terraform output -raw frontend_public_ip', returnStdout: true).trim()
                    
                    
                    echo "Frontend URL: http://${frontendPublicIp}"

                    
                    sh "curl -I http://${frontendPublicIp}"
                }
            }
        }
    }

    post {
        always {
            script {
                
                dir('terraform') {
                    sh 'terraform destroy -auto-approve'
                }
            }
        }
    }
}
