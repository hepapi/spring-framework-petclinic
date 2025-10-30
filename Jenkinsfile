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
    stage('Setup Docker') {
      steps {
        container('builder') {
          sh '''
            apt-get update -qq
            apt-get install -y -qq ca-certificates curl gnupg lsb-release
            mkdir -p /etc/apt/keyrings
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
            apt-get update -qq
            apt-get install -y -qq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
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
            apt-get install -y openjdk-17-jdk maven
            ./mvnw clean package -DskipTests
          '''
        }
      }
    }

    stage('Build & Push Docker Image') {
      steps {
        container('builder') {
          withCredentials([usernamePassword(credentialsId: 'nexus-cred', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
            sh '''
              echo "$PASS" | docker login https://$REGISTRY -u "$USER" --password-stdin
              docker build -t $REGISTRY/$REPO_PATH/$IMAGE_NAME:$IMAGE_TAG .
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
