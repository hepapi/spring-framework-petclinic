pipeline {
  agent any

  environment {
    REGISTRY   = "my-nexus-repository-manager.nexus.svc.cluster.local:8082"
    REPO_PATH  = "repository/nexusimagerepository"
    IMAGE_NAME = "spring-petclinic"
  }

  stages {
    stage('Checkout') {
      steps {
        git branch: 'main', url: 'https://github.com/hepapi/spring-framework-petclinic.git'
      }
    }

    stage('Login to Nexus') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'nexus-docker-creds', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
          sh '''
            echo "🔐 Nexus login..."
            echo "$PASS" | docker login $REGISTRY -u "$USER" --password-stdin
          '''
        }
      }
    }

    stage('Build Docker Image') {
      steps {
        sh '''
          IMAGE_TAG=$(git rev-parse --short HEAD)
          echo "📦 Building Docker image $IMAGE_TAG ..."
          docker build -t $REGISTRY/$REPO_PATH/$IMAGE_NAME:$IMAGE_TAG -f Dockerfile .
        '''
      }
    }

    stage('Push Docker Image to Nexus') {
      steps {
        sh '''
          IMAGE_TAG=$(git rev-parse --short HEAD)
          echo "🚀 Pushing Docker image to Nexus..."
          docker push $REGISTRY/$REPO_PATH/$IMAGE_NAME:$IMAGE_TAG
        '''
      }
    }
  }

  post {
    success {
      echo "✅ Image başarıyla Nexus’a pushlandı!"
    }
    failure {
      echo "❌ Pipeline hata verdi."
    }
  }
}
