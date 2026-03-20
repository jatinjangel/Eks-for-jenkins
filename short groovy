pipeline {
    agent any

    stages {

        // 🔽 1. PULL CODE
        stage('Pull Code') {
            steps {
                git branch: 'main', url: 'https://github.com/jatinjangel/Eks-for-jenkins.git'
            }
        }

        // 🔨 2. TERRAFORM INIT + PLAN
        stage('Terraform Plan') {
            steps {
                sh '''
                terraform init
                terraform validate
                terraform plan -out=tfplan
                '''
            }
        }

        // ✋ 3. APPROVAL
        stage('Approval') {
            steps {
                input message: 'Apply Terraform?', ok: 'Yes'
            }
        }

        // 🚀 4. APPLY
        stage('Terraform Apply') {
            steps {
                sh 'terraform apply -auto-approve tfplan'
            }
        }
    }

    post {
        success {
            echo "✅ Success"
        }
        failure {
            echo "❌ Failed"
        }
    }
}
