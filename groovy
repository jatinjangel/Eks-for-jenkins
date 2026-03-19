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
                timeout(time: 30, unit: 'MINUTES') {
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
