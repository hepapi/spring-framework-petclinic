pipeline {
  agent {
    kubernetes {
      yaml """
apiVersion: v1
kind: Pod
metadata:
  name: docker-build-pod
spec:
  serviceAccountName: jenkins
  containers:
    - name: builder
      image: ubuntu:22.04
      tty: true
      command:
        - cat
      volumeMounts:
        - name: workspace-volume
          mountPath: /home/jenkins/agent
  volumes:
    - name: workspace-volume
      emptyDir: {}
"""
    }
  }

  environment {
    REGISTRY = "nexus.hepapi.com"
    REPO_PATH = "repository/docker-hosted"
    IMAGE_NAME = "spring-petclinic"
    IMAGE_TAG = "latest"
  }

  stages {
    stage('Setup Build Environment') {
      steps {
        container('builder') {
          sh '''
            echo "🔧 Ortam hazırlanıyor..."
            apt-get update -qq
            apt-get install -y -qq \
              ca-certificates curl gnupg lsb-release git openjdk-17-jdk maven \
              docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

            echo "✅ Ortam hazır!"
            java -version
            git --version
            docker --version
          '''
        }
      }
    }

    stage('Checkout') {
      steps {
        container('builder') {
          git branch: 'main', url: 'https://github.com/hepapi/spring-framework-petclinic.git'
        }
      }
    }

    stage('Build JAR') {
      steps {
        container('builder') {
          sh '''
            echo "🏗️ Maven build başlıyor..."
            ./mvnw clean package -DskipTests
            echo "✅ Build tamamlandı!"
          '''
        }
      }
    }

    stage('Build & Push Docker Image') {
      steps {
        container('builder') {
          withCredentials([usernamePassword(credentialsId: 'nexus-cred', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
            sh '''
              echo "🔐 Nexus login..."
              echo "$PASS" | docker login https://$REGISTRY -u "$USER" --password-stdin

              echo "📦 Image build ediliyor..."
              docker build -t $REGISTRY/$REPO_PATH/$IMAGE_NAME:$IMAGE_TAG .

              echo "🚀 Image push ediliyor..."
              docker push $REGISTRY/$REPO_PATH/$IMAGE_NAME:$IMAGE_TAG
            '''
          }
        }
      }
    }
  }

  post {
    success {
      echo "✅ Image başarıyla pushlandı: $REGISTRY/$REPO_PATH/$IMAGE_NAME:$IMAGE_TAG"
    }
    failure {
      echo "❌ Pipeline hata verdi."
    }
  }
}
