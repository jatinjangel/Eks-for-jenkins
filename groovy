pipeline {
    agent any

    environment {
        TF_DIR = '.'
    }

    stages {

        // 🔽 1. PULL CODE
        stage('Pull Code') {
            steps {
                git branch: 'main', url: 'https://github.com/jatinjangel/Eks-for-jenkins.git'
            }
        }

        // 🔨 2. TERRAFORM INIT + VALIDATE
        stage('Terraform Init & Validate') {
            steps {
                dir("${TF_DIR}") {
                    sh '''
                    terraform init
                    terraform validate
                    '''
                }
            }
        }

        // 📊 3. PLAN
        stage('Terraform Plan') {
            steps {
                dir("${TF_DIR}") {
                    sh 'terraform plan -out=tfplan'
                }
            }
        }

        // ✋ 4. APPROVAL
        stage('Approval') {
            steps {
                input message: 'Do you want to apply Terraform?', ok: 'Yes'
            }
        }

        // 🚀 5. APPLY
        stage('Terraform Apply') {
            steps {
                dir("${TF_DIR}") {
                    sh 'terraform apply -auto-approve tfplan'
                }
            }
        }

        // 💣 6. DESTROY (optional)
        stage('Terraform Destroy') {
            when {
                expression { return false }   // default off
            }
            steps {
                dir("${TF_DIR}") {
                    sh 'terraform destroy -auto-approve'
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
