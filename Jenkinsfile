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
                            sh 'terraform apply -auto-approve -var "aws_access_key=$AWS_ACCESS_KEY_ID" -var "aws_secret_key=$AWS_SECRET_ACCESS_KEY"'
                        }
                    }
                }
            }
        }

        stage('Deploy_Apps') {
            steps {
                withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'jai-aws-creds', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    dir(TERRAFORM_DIR) {
                        script {
                            sh 'terraform apply -auto-approve -var "aws_access_key=$AWS_ACCESS_KEY_ID" -var "aws_secret_key=$AWS_SECRET_ACCESS_KEY"'
                        }

                        script {
                            def frontend_ip = sh(script: 'terraform output -raw frontend_public_ip', returnStdout: true).trim()
                            sh """
                                ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_PATH} ubuntu@${frontend_ip} 'bash /tmp/frontend.sh'
                            """
                        }

                        script {
                            def backend_ip = sh(script: 'terraform output -raw backend_private_ip', returnStdout: true).trim()
                            sh """
                                ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_PATH} ubuntu@${backend_ip} 'bash /tmp/backend.sh'
                            """
                        }
                    }
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
            withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'jai-aws-creds', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                dir(TERRAFORM_DIR) {
                    sh 'terraform destroy -auto-approve -var "aws_access_key=$AWS_ACCESS_KEY_ID" -var "aws_secret_key=$AWS_SECRET_ACCESS_KEY"'
                }
            }
        }
    }
}
