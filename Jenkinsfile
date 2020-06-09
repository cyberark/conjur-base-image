pipeline {
  agent { label 'executor-v2' }

  parameters { 
    booleanParam(name: 'FORCE_OPENSSL_BUILDER', defaultValue: false, description: 'Forces build of openssl-builder docker image')
    booleanParam(name: 'FORCE_RUBY_BUILDERS', defaultValue: false, description: 'Forces build of *-ruby-builder docker image') 
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
    stage ('Build and push subsequent builder images') {
      parallel {
        stage ('Build and push phusion-ruby-builder image') {
          steps {
            sh "./phusion-ruby-builder/build.sh ${params.FORCE_RUBY_BUILDERS}"
            sh "./phusion-ruby-builder/push.sh ${params.FORCE_RUBY_BUILDERS}"
          }
        }
        stage ('Build and push ubuntu-ruby-builder image') {
          steps {
            sh "./ubuntu-ruby-builder/build.sh ${params.FORCE_RUBY_BUILDERS}"
            sh "./ubuntu-ruby-builder/push.sh ${params.FORCE_RUBY_BUILDERS}"
          }
        }
        stage ('Build and tag postgres-client-builder image') {
          steps {
            sh "./postgres-client-builder/build.sh"
            sh "./postgres-client-builder/tag.sh"
          }
        }
      }
    }
    stage ('Build fips base images') {
      parallel {
        stage ('Build phusion-ruby-fips image') {
          steps {
            sh "./phusion-ruby-fips/build.sh ${TAG}"
          }
        }
        stage ('Build ubuntu-ruby-fips image') {
          steps {
            sh "./ubuntu-ruby-fips/build.sh ${TAG}"
          }
        }
      }
    }
  }

  post {
    always {
      cleanupAndNotify(currentBuild.currentResult, "#development")
    }
  }
}