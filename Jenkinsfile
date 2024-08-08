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
                        script {
                            sh 'terraform init'
                            sh 'terraform apply -auto-approve'
                        }
                    }
                }
            }
        }

    stage('Cleanup') {
        steps {
            cleanWs()
        }
    }    

    stage('Deploy_Apps') {
    steps {
        withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'jai-aws-creds', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
            dir(TERRAFORM_DIR) {
                script {
                    def frontend_ip = sh(script: 'terraform output -raw frontend_public_ip', returnStdout: true).trim()
                    def backend_ip = sh(script: 'terraform output -raw backend_private_ip', returnStdout: true).trim()
                    def bastion_ip = sh(script: 'terraform output -raw bastion_public_ip', returnStdout: true).trim()

                   

                    sh """
                        scp -v -o StrictHostKeyChecking=no -i ${SSH_KEY_PATH} /frontend/index.html ubuntu@${frontend_ip}:/tmp/index.html
                        ssh -v -o StrictHostKeyChecking=no -i ${SSH_KEY_PATH} ubuntu@${frontend_ip} 'sudo mv /tmp/index.html /usr/share/nginx/html/index.html'
                    """

                    sh """
                        ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_PATH} ubuntu@${frontend_ip} 'sudo bash /tmp/frontend.sh'
                    """

                    sh """
                        ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_PATH} -o ProxyCommand="ssh -i ${SSH_KEY_PATH} -W %h:%p ubuntu@${bastion_ip}" ubuntu@${backend_ip} 'sudo bash /tmp/backend.sh'
                    """
                }
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
