pipeline {
    agent any
    environment {
        TERRAFORM_DIR = 'terraform'
        SSH_KEY_PATH = '/home/sharedKey/web-dev-keyPair.pem'
    }
    stages {
        stage('Create_Infra') {
            steps {
                withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'jai-aws-creds', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    dir(TERRAFORM_DIR) {
                        script {
                            sh 'terraform init'
                            sh 'terraform apply -auto-approve'
                        }
                    }
                }
            }
        }    

    stage('Verify Files') {
        steps {
                sh 'pwd'
                sh 'ls -l ./backend.sh'
                
        }
    }
    stage('Destroy infra') {
        steps {
                sh 'terraform destroy -auto-approve'
        }
    }
        
    stage('Deploy_Apps') {
    steps {
        withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'jai-aws-creds', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
            
                script {
                    def frontend_ip
                    def backend_ip
                    def bastion_ip
                    
                    dir(TERRAFORM_DIR) {
                        frontend_ip = sh(script: 'terraform output -raw frontend_public_ip', returnStdout: true).trim()
                        backend_ip = sh(script: 'terraform output -raw backend_private_ip', returnStdout: true).trim()
                        bastion_ip = sh(script: 'terraform output -raw bastion_public_ip', returnStdout: true).trim()
                    }
                    
                    
                    sh """
                        sudo chmod 400 ${SSH_KEY_PATH}
                        sudo scp -v -o StrictHostKeyChecking=no -i ${SSH_KEY_PATH} ./frontend/index.html ubuntu@${frontend_ip}:/tmp/index.html
                        sudo ssh -v -o StrictHostKeyChecking=no -i ${SSH_KEY_PATH} ubuntu@${frontend_ip} 'sudo apt update'
                        sudo ssh -v -o StrictHostKeyChecking=no -i ${SSH_KEY_PATH} ubuntu@${frontend_ip} 'sudo apt install -y nginx'
                        sudo ssh -v -o StrictHostKeyChecking=no -i ${SSH_KEY_PATH} ubuntu@${frontend_ip} 'sudo mv /tmp/index.html /usr/share/nginx/html/index.html'
                    """
                    sh """
                        
                        sudo sed -i "s|http://BACKEND_IP:5000/submit|http://${backend_ip}:5000/submit|g" ./frontend/index.html
                        sudo scp -v -o StrictHostKeyChecking=no -i ${SSH_KEY_PATH} ./frontend/index.html ubuntu@${frontend_ip}:/tmp/index.html
                        sudo ssh -v -o StrictHostKeyChecking=no -i ${SSH_KEY_PATH} ubuntu@${frontend_ip} 'sudo mv /tmp/index.html /usr/share/nginx/html/index.html'
                    """

                    sh """
                        sudo ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_PATH} -o ProxyCommand="ssh -i ${SSH_KEY_PATH} -W %h:%p ubuntu@${bastion_ip}" ubuntu@${backend_ip} 'hostname'
                    """
                    // added -vvv to check logs for tunning not happening
                   sh """
                        sudo scp -v -o StrictHostKeyChecking=no -i ${SSH_KEY_PATH} ./backend.sh ubuntu@${backend_ip}:/tmp/backend.sh
                        sudo ssh -vvv -o StrictHostKeyChecking=no -i ${SSH_KEY_PATH} -o ProxyCommand="ssh -i ${SSH_KEY_PATH} -W %h:%p ubuntu@${bastion_ip}" ubuntu@${backend_ip} 'sudo chmod +x /tmp/backend.sh'
                        sudo ssh -vvv -o StrictHostKeyChecking=no -i ${SSH_KEY_PATH} -o ProxyCommand="ssh -i ${SSH_KEY_PATH} -W %h:%p ubuntu@${bastion_ip}" ubuntu@${backend_ip} 'sudo /tmp/backend.sh'
                    """
                
                    
                }
        }
    }
}





        stage('Test_Solution') {
            steps {
                withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'jai-aws-creds', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    script {
                        def frontend_ip = sh(script: 'terraform output -raw frontend_public_ip', returnStdout: true).trim()
                        echo "Frontend Public IP: ${frontend_ip}"
                        sh "curl -I http://${frontend_ip}"
                    }
                }
            }
        }
    }
}
