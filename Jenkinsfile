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
    - name: docker
      image: docker:27-dind
      securityContext:
        privileged: true
      args:
        - --host=tcp://0.0.0.0:2375
      volumeMounts:
        - name: docker-storage
          mountPath: /var/lib/docker
    - name: builder
      image: docker:27-cli
      tty: true
      env:
        - name: DOCKER_HOST
          value: tcp://localhost:2375
      volumeMounts:
        - name: docker-storage
          mountPath: /var/lib/docker
        - name: workspace-volume
          mountPath: /home/jenkins/agent
  volumes:
    - name: docker-storage
      emptyDir: {}
    - name: workspace-volume
      emptyDir: {}
"""
    }
  }

  environment {
    REGISTRY   = "nexus.hepapi.com"
    REPO_PATH  = "repository/docker-hosted"
    IMAGE_NAME = "spring-petclinic"
  }

  stages {
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
          sh 'apk add --no-cache openjdk17 maven'
          sh './mvnw clean package -DskipTests'
        }
      }
    }

    stage('Build & Push Docker Image') {
      steps {
        container('builder') {
          withCredentials([usernamePassword(credentialsId: 'nexus-docker-creds', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
            sh '''
              echo "🔐 Nexus login..."
              echo "$PASS" | docker login https://$REGISTRY -u "$USER" --password-stdin

              IMAGE_TAG=$(git rev-parse --short HEAD)
              echo "📦 Building image $IMAGE_TAG"
              docker build -t $REGISTRY/$REPO_PATH/$IMAGE_NAME:$IMAGE_TAG -f Dockerfile .

              echo "🚀 Pushing image..."
              docker push $REGISTRY/$REPO_PATH/$IMAGE_NAME:$IMAGE_TAG
            '''
          }
        }
      }
    }
  }

  post {
    success {
      echo "✅ Image başarıyla pushlandı!"
    }
    failure {
      echo "❌ Pipeline hata verdi."
    }
  }
}
