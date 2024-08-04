pipeline {
    agent any

    environment {
        
        TF_VAR_aws_region = 'eu-north-1'  
        TF_VAR_vpc_cidr = '10.0.0.0/16'   
        TF_VAR_public_subnet_cidr = '10.0.1.0/24' 
        TF_VAR_private_subnet_cidr = '10.0.2.0/24' 
        SSH_KEY = credentials('my-ssh-key') 
    }

    stages {
        stage('Create_Infra') {
            steps {
                script {
                    
                    sh 'terraform init'
                    sh 'terraform apply -auto-approve'
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
                    
                    def frontendPublicDns = sh(script: 'terraform output -raw frontend_public_dns', returnStdout: true).trim()
                    
                    
                    echo "Frontend URL: http://${frontendPublicDns}/"

                   
                    sh "curl -I http://${frontendPublicDns}/"
                }
            }
        }
    }

    post {
        always {
            
            sh 'terraform destroy -auto-approve'
        }
    }
}
