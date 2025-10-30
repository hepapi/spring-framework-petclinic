pipeline {
  agent {
    kubernetes {
      yaml """
apiVersion: v1
kind: Pod
metadata:
  name: kaniko-build-pod
spec:
  serviceAccountName: jenkins
  containers:
    - name: kaniko
      image: gcr.io/kaniko-project/executor:latest
      tty: true
      volumeMounts:
        - name: kaniko-secret
          mountPath: /kaniko/.docker/
  volumes:
    - name: kaniko-secret
      emptyDir: {}
"""
    }
  }

  environment {
    IMAGE_NAME = "spring-petclinic"
    REGISTRY   = "nexus.hepapi.com/repository/nexusimagerepository"
  }

  stages {
    stage('Checkout') {
      steps {
        container('kaniko') {
          git branch: 'main', url: 'https://github.com/hepapi/spring-framework-petclinic.git'
        }
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
        container('kaniko') {
          sh './mvnw clean package -DskipTests'
        }
      }
    }

    stage('Build & Push Image (Kaniko)') {
      steps {
        container('kaniko') {
          withCredentials([usernamePassword(credentialsId: 'nexus-docker-creds', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
            sh """
              mkdir -p /kaniko/.docker
              echo "{\"auths\":{\"${REGISTRY}\":{\"username\":\"$USER\",\"password\":\"$PASS\"}}}" > /kaniko/.docker/config.json

              /kaniko/executor \
                --context $PWD \
                --dockerfile spring-petclinic/Dockerfile \
                --destination ${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG} \
                --skip-tls-verify \
                --reproducible
            """
          }
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
