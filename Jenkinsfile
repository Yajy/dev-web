pipeline {
    agent any
    environment {
        TERRAFORM_DIR = 'terraform'
        SSH_KEY_PATH = '/home/yajy/web-dev-keyPair.pem'
    }
    stages {
        stage('Create_Infra') {
            steps {
                withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'jai-aws-creds', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    dir(TERRAFORM_DIR) {
                        sh 'terraform init'
                        sh 'terraform apply -auto-approve'
                    }
                }
            }
        }    
        
        stage('Deploy_Apps') {
            steps {
                withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'jai-aws-creds', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    script {
                        try {
                            def frontend_ip
                            def backend_ip
                            def bastion_ip
                            dir(TERRAFORM_DIR) {
                                frontend_ip = sh(script: 'terraform output -raw frontend_public_ip', returnStdout: true).trim()
                                backend_ip = sh(script: 'terraform output -raw backend_private_ip', returnStdout: true).trim()
                                bastion_ip = sh(script: 'terraform output -raw bastion_public_ip', returnStdout: true).trim()
                            }
                            
                            // Frontend deployment
                            sh """
                                set -e
                                scp -o StrictHostKeyChecking=accept-new -i ${SSH_KEY_PATH} ./frontend.sh ubuntu@${frontend_ip}:/home/ubuntu
                                
                                
                                sed -i "s|http://BACKEND_IP:5000/submit|http://${backend_ip}:5000/submit|g" ./frontend/index.html
                                scp -o StrictHostKeyChecking=accept-new -i ${SSH_KEY_PATH} ./frontend/index.html ubuntu@${frontend_ip}:/home/ubuntu/index.html

                            
                                ssh -o StrictHostKeyChecking=accept-new -i ${SSH_KEY_PATH} ubuntu@${frontend_ip} 'sudo chmod +x frontend.sh' 
                                
                                ssh -o StrictHostKeyChecking=accept-new -i ${SSH_KEY_PATH} ubuntu@${frontend_ip} './frontend.sh'
                            """
                            
                            // Backend deployment
                            sh """
                                set -ex
                                
                                echo "Copying backend script..."
                                scp -o ProxyCommand="ssh -i ${SSH_KEY_PATH} -o StrictHostKeyChecking=no -W %h:%p ubuntu@${bastion_ip}" -o StrictHostKeyChecking=no -i ${SSH_KEY_PATH} ./backend.sh ubuntu@${backend_ip}:/tmp/backend.sh

                                
                                echo "Executing backend script..."
                                ssh -o ProxyCommand="ssh -i ${SSH_KEY_PATH} -o StrictHostKeyChecking=no -W %h:%p ubuntu@${bastion_ip}" -o StrictHostKeyChecking=no -i ${SSH_KEY_PATH} ubuntu@${backend_ip} 'sudo chmod +x /tmp/backend.sh && sudo /tmp/backend.sh'
                            """
                        } catch (Exception e) {
                            currentBuild.result = 'FAILURE'
                            error("Deployment failed: ${e.message}")
                        }
                    }
                }
            }
        }

        stage('Test_Solution') {
            steps {
                withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'jai-aws-creds', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    script {
                        dir(TERRAFORM_DIR) {
                            def frontend_ip = sh(script: 'terraform output -raw frontend_public_ip', returnStdout: true).trim()
                            echo "Frontend Public IP: ${frontend_ip}"
                            sh "curl -I http://${frontend_ip}"
                        }
                    }
                }
            }
        }
    }
}
