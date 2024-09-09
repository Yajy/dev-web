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
                                ssh -o StrictHostKeyChecking=accept-new -i ${SSH_KEY_PATH} ubuntu@${frontend_ip} 'sudo apt update && sudo apt install -y nginx'
                                sed -i "s|http://BACKEND_IP:5000/submit|http://${backend_ip}:5000/submit|g" ./frontend/index.html
                                scp -o StrictHostKeyChecking=accept-new -i ${SSH_KEY_PATH} ./frontend/index.html ubuntu@${frontend_ip}:/tmp/index.html
                                ssh -o StrictHostKeyChecking=accept-new -i ${SSH_KEY_PATH} ubuntu@${frontend_ip} 'sudo mv /tmp/index.html /usr/share/nginx/html/index.html'
                            """
                            
                            // Backend deployment
                            sh """
                                set -ex
                                echo "Adding bastion host to known hosts..."
                                ssh-keyscan -H ${bastion_ip} >> ~/.ssh/known_hosts
                                
                                echo "Checking connectivity to backend from bastion..."
                                ssh -i ${SSH_KEY_PATH} ubuntu@${bastion_ip} 'ping -c 4 ${backend_ip}'
                                
                                echo "Adding backend to known hosts via bastion..."
                                ssh -i ${SSH_KEY_PATH} ubuntu@${bastion_ip} "ssh-keyscan -H ${backend_ip} >> ~/.ssh/known_hosts"
                                
                                echo "Copying backend script..."
                                scp -o ProxyCommand="ssh -i ${SSH_KEY_PATH} -W %h:%p ubuntu@${bastion_ip}" -i ${SSH_KEY_PATH} ./backend.sh ubuntu@${backend_ip}:/tmp/backend.sh
                                
                                echo "Executing backend script..."
                                ssh -o ProxyCommand="ssh -i ${SSH_KEY_PATH} -W %h:%p ubuntu@${bastion_ip}" -i ${SSH_KEY_PATH} ubuntu@${backend_ip} 'sudo chmod +x /tmp/backend.sh && sudo /tmp/backend.sh'
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
