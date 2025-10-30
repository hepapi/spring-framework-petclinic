pipeline {
  agent any

  environment {
    REGISTRY   = "nexus.hepapi.com"
    REPO_PATH  = "repository/docker-hosted"
    IMAGE_NAME = "spring-petclinic"
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

    stage('Build & Push Docker Image') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'nexus-docker-creds', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
          sh '''
            echo "🔐 Nexus login..."
            echo "$PASS" | docker login https://$REGISTRY -u "$USER" --password-stdin

            IMAGE_TAG=$(git rev-parse --short HEAD)
            echo "📦 Building image..."
            docker build -t $REGISTRY/$REPO_PATH/$IMAGE_NAME:$IMAGE_TAG .

            echo "🚀 Pushing image..."
            docker push $REGISTRY/$REPO_PATH/$IMAGE_NAME:$IMAGE_TAG
          '''
        }
      }
    }
  }

  post {
    success {
      echo "✅ Image pushlandı: $REGISTRY/$REPO_PATH/$IMAGE_NAME:$IMAGE_TAG"
    }
    failure {
      echo "❌ Pipeline hata verdi."
    }
  }
}
