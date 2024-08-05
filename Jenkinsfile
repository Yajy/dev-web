pipeline {
    agent any

    environment {
        SSH_KEY = credentials('web-dev-keyPair')
        AWS_ACCESS_KEY_ID = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
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
                        ssh -i "${SSH_KEY}" ubuntu@${frontendPublicIp} "cd /path/to/frontend && ./frontend.sh ${backendPrivateIp}"
                    '''

                    sh '''
                        ssh -i "${SSH_KEY}" ubuntu@${backendPrivateIp} "cd /path/to/backend && ./backend.sh"
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

    
}
