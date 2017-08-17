pipeline {
    agent any

    stages {
        stage('Build for production') {
            steps {
                sh "docker build --target release -t fb11:${env.BRANCH_NAME} ."
            }
        }
    }
}