pipeline {
  agent any

  environment {
    REGISTRY = "nexus.hepapi.com"
    REPO_PATH = "repository/docker-hosted"
    IMAGE_NAME = "spring-petclinic"
    IMAGE_TAG = "latest"
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build JAR') {
      steps {
        sh '''
          echo "🔧 Building Maven project..."
          ./mvnw clean package -DskipTests
        '''
      }
    }

    stage('Build Docker Image') {
      steps {
        sh '''
          echo "📦 Building Docker image..."
          docker build -t $IMAGE_NAME:$IMAGE_TAG .
        '''
      }
    }

    stage('Login to Nexus') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'nexus-cred', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
          sh '''
            echo "🔐 Logging in to Nexus..."
            echo "$PASS" | docker login $REGISTRY -u "$USER" --password-stdin
          '''
        }
      }
    }

    stage('Push to Nexus') {
      steps {
        sh '''
          echo "🚀 Pushing image to Nexus..."
          docker tag $IMAGE_NAME:$IMAGE_TAG $REGISTRY/$REPO_PATH/$IMAGE_NAME:$IMAGE_TAG
          docker push $REGISTRY/$REPO_PATH/$IMAGE_NAME:$IMAGE_TAG
        '''
      }
    }
  }

  post {
    success {
      echo "✅ Image başarıyla Nexus'a pushlandı: $REGISTRY/$REPO_PATH/$IMAGE_NAME:$IMAGE_TAG"
    }
    failure {
      echo "❌ Pipeline hata verdi."
    }
  }
}
