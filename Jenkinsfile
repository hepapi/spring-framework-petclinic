pipeline {
  agent any

  environment {
    REGISTRY = "my-nexus-repository-manager.nexus.svc.cluster.local:8082"
    IMAGE_NAME = "spring-petclinic"
    IMAGE_TAG = "latest"
  }

  stages {

    stage('Checkout') {
      steps {
        git branch: 'main', url: 'https://github.com/hepapi/spring-framework-petclinic.git'
      }
    }

    stage('Build JAR') {
      steps {
        sh '''
          echo "🔧 Building Maven project..."
          apt-get update -qq
          apt-get install -y -qq openjdk-17-jdk maven
          ./mvnw clean package -DskipTests
        '''
      }
    }

    stage('Build & Push Docker Image') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'nexus-cred', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
          sh '''
            echo "🔐 Logging into Nexus..."
            echo "$PASS" | docker login http://$REGISTRY -u "$USER" --password-stdin

            echo "📦 Building Docker image..."
            docker build -t $REGISTRY/$IMAGE_NAME:$IMAGE_TAG .

            echo "🚀 Pushing image to Nexus..."
            docker push $REGISTRY/$IMAGE_NAME:$IMAGE_TAG
          '''
        }
      }
    }
  }

  post {
    success {
      echo "✅ Image başarıyla pushlandı: $REGISTRY/$IMAGE_NAME:$IMAGE_TAG"
    }
    failure {
      echo "❌ Pipeline hata verdi."
    }
  }
}
