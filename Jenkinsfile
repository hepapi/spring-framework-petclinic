pipeline {
    agent any

    environment {
        IMAGE_NAME = "spring-petclinic"
        IMAGE_TAG  = "latest"
        REGISTRY   = "nexus.devops.digiturk.net"   // kendi Nexus Docker registry adresin
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/hepapi/spring-framework-petclinic.git'
            }
        }

        stage('Build JAR') {
            steps {
                sh './mvnw clean package -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
            }
        }

        stage('Push to Nexus') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'nexus-docker-creds', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                    sh """
                      echo "$PASS" | docker login ${REGISTRY} -u "$USER" --password-stdin
                      docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}
                      docker push ${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}
                    """
                }
            }
        }
    }

    post {
        success {
            echo "✅ Image başarıyla Nexus'a pushlandı."
        }
        failure {
            echo "❌ Pipeline hata verdi."
        }
    }
}
