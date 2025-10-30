pipeline {
  agent any

  environment {
    IMAGE_NAME = "spring-petclinic"
    REGISTRY   = "nexus.hepapi.com/repository/nexusimagerepository"
  }

  stages {
    stage('Checkout') {
      steps {
        git branch: 'main', url: 'https://github.com/hepapi/spring-framework-petclinic.git'
      }
    }

    stage('Set IMAGE_TAG') {
      steps {
        script {
          IMAGE_TAG = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
          echo "📦 IMAGE_TAG = ${IMAGE_TAG}"
        }
      }
    }

    stage('Build JAR') {
      steps {
        sh './mvnw clean package -DskipTests'
      }
    }

    stage('Build & Push Image') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'nexus-docker-creds', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
          sh """
            echo "${PASS}" | docker login ${REGISTRY} -u "${USER}" --password-stdin

            docker build -t ${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG} -f Dockerfile .
            docker push ${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}
          """
        }
      }
    }
  }

  post {
    success {
      echo "✅ Image başarıyla Nexus'a pushlandı: ${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"
    }
    failure {
      echo "❌ Pipeline hata verdi."
    }
  }
}
