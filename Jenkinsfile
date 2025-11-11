@Library('poc-env-micro-ci-lib') _

def SERVICE = 'spring-petclinic'
def ENV = 'dev'

pipeline {
  agent {
    kubernetes {
      label 'k8s-agent-multi'
    }
  }

  stages {

    stage('Docker Build & Push') {
      steps {
        dockerBuildPush(
          service: SERVICE,
          environment: ENV,
          gitRepo: 'https://github.com/hepapi/spring-framework-petclinic.git',
          gitBranch: 'main',
          dockerfileName: 'Dockerfile',
          contextPath: "."
        )
      }
    }

    stage('Static & Security Analysis') {
      steps {
        securityScan(
          sonar: 'enable',
          conftest: 'enable',
          trivy: 'enable'
        )
      }
    }

    stage('Manual Approval') {
      steps {
        manualApproval(approval: 'enable')
      }
    }

    stage('Helm Package & Push') {
      steps {
        helmPackagePush(
          service: SERVICE,
          environment: ENV,
          helmValuesFile: "non-prod/${ENV}/${SERVICE}-values.yaml",
          chartName: "${SERVICE}-${ENV}"
        )
      }
    }
  }

  post {
    success {
      notifyStatus(status: 'success')
    }
    failure {
      notifyStatus(status: 'failure')
    }
  }
}
