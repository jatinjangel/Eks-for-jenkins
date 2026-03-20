pipeline {
    agent any

    stages {
        stage('Git Pull') {
            steps {
                git branch: 'main', url: 'https://github.com/jatinjangel/Eks-for-jenkins.git'
            }
        }

        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Terraform Plan') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    sh 'terraform plan -var-file="dev.tfvars"'
                }
            }
        }

        stage('Approval') {
            steps {
                input 'Ask for input approval'
            }
        }

        stage('Terraform Apply') {
            steps {
                timeout(time: 30, unit: 'MINUTES') {pipeline {
    agent any

    environment {
        AWS_REGION = 'eu-north-1'
        CLUSTER_NAME = 'eks-cluster'
        TF_DIR = '.'
    }

    stages {

        // 🔽 1. PULL CODE
        stage('Pull Code') {
            steps {
                git branch: 'main', url: 'https://github.com/jatinjangel/Eks-for-jenkins.git'
            }
        }

        // 🔨 2. BUILD (Terraform Plan)
        stage('Build (Terraform Plan)') {
            steps {
                dir("${TF_DIR}") {
                    sh '''
                    terraform init
                    terraform validate
                    terraform plan -out=tfplan
                    '''
                }
            }
        }

        // ✋ 3. MANUAL APPROVAL
        stage('Approval') {
            steps {
                input message: 'Do you want to deploy EKS cluster?', ok: 'Approve'
            }
        }

        // 🚀 4. DEPLOY
        stage('Deploy (Terraform Apply)') {
            steps {
                dir("${TF_DIR}") {
                    sh 'terraform apply -auto-approve tfplan'
                }
            }
        }
    }

    post {
        success {
            echo "✅ Deployment Successful!"
        }
        failure {
            echo "❌ Deployment Failed!"
        }
    }
}
                    sh 'terraform apply -var-file="dev.tfvars" --auto-approve'
                }
            }
        }

        stage('Terraform Destroy') {
            steps {
                timeout(time: 30, unit: 'MINUTES') {
                    sh 'terraform destroy -var-file="dev.tfvars" --auto-approve'
                }
            }
        }
    }
}
