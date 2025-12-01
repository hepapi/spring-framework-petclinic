@Library('poc-env-micro-ci-lib') _

pipeline {
  agent {
    kubernetes {
      label 'k8s-agent-multi'
    }
  }

  environment {
    SERVICE = 'spring-petclinic'
    ENV     = 'dev'
  }

  stages {

    stage('Docker Build & Push') {
      steps {
        dockerBuildPush(
          service: SERVICE,
          environment: ENV,
          gitRepo: 'https://github.com/hepapi/spring-framework-petclinic.git'
        )
      }
    }

    stage('Security Scan') {
      steps {
        securityScan(
          trivy: 'enable',
          conftest: 'enable',
          sonar: 'enable'
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
