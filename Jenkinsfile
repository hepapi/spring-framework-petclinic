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
      args: ["--insecure-registry=nexus.hepapi.com"]
    - name: builder
      image: docker:27-cli
      command:
        - cat
      tty: true
      volumeMounts:
        - name: docker-sock
          mountPath: /var/run
        - name: docker-config
          mountPath: /root/.docker
  volumes:
    - name: docker-sock
      emptyDir: {}
    - name: docker-config
      emptyDir: {}
"""
    }
  }

  environment {
    IMAGE_NAME = "spring-petclinic"
    REGISTRY   = "my-nexus-repository-manager.nexus.svc.cluster.local:8082"
  }

  stages {
    stage('Checkout') {
      steps {
        container('builder') {
          git branch: 'main', url: 'https://github.com/hepapi/spring-framework-petclinic.git'
        }
      }
    }

    stage('Set IMAGE_TAG') {
      steps {
        container('builder') {
          script {
            sh 'git config --global --add safe.directory /home/jenkins/agent/workspace/cicd-pipeline'
            IMAGE_TAG = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
            echo "📦 IMAGE_TAG = ${IMAGE_TAG}"
          }
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
              echo "${PASS}" | docker login ${REGISTRY} -u "${USER}" --password-stdin
              docker build -t ${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG} -f Dockerfile .
              docker push ${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}
            '''
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
