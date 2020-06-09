pipeline {
  agent { label 'executor-v2' }

  parameters { 
    booleanParam(name: 'FORCE_OPENSSL_BUILDER', defaultValue: false, description: 'Forces build of openssl-builder docker image') 
  }

  environment {
    TAG = sh(returnStdout: true, script: "git rev-parse --short HEAD | tr -d '\n'")
  }

  stages {
    stage ('Build and push openssl-builder image') {
      steps {
        sh "./openssl-builder/build.sh ${params.FORCE_OPENSSL_BUILDER}"
        sh "./openssl-builder/push.sh ${params.FORCE_OPENSSL_BUILDER}"
      }
    }
  }

  post {
    always {
      cleanupAndNotify(currentBuild.currentResult, "#development")
    }
  }
}
