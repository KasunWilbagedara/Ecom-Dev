pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = 'dockerhub-creds' // Jenkins credential ID
        DOCKERHUB_USER = 'kasunwilbagedara'
        BACKEND_IMAGE = 'ecom_devops-backend'
        FRONTEND_IMAGE = 'ecom_devops-frontend'
        ADMIN_IMAGE = 'ecom_devops-admin'
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/KasunWilbagedara/Ecom-Dev.git'
            }
        }

        stage('Build Docker Images') {
            steps {
                sh 'docker build -t $DOCKERHUB_USER/$BACKEND_IMAGE ./backend'
                sh 'docker build -t $DOCKERHUB_USER/$FRONTEND_IMAGE ./frontend'
                sh 'docker build -t $DOCKERHUB_USER/$ADMIN_IMAGE ./admin'
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: "$DOCKERHUB_CREDENTIALS", usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                    sh 'docker push $DOCKERHUB_USER/$BACKEND_IMAGE'
                    sh 'docker push $DOCKERHUB_USER/$FRONTEND_IMAGE'
                    sh 'docker push $DOCKERHUB_USER/$ADMIN_IMAGE'
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline finished.'
        }
    }
}
