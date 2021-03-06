pipeline {
  agent { label 'executor-v2' }

  parameters {
    booleanParam(name: 'PUBLISH_DOCKERHUB', defaultValue: false,
                 description: 'Publish images to DockerHub')
  }

  triggers {
    cron(getDailyCronString())
  }

  stages {
    stage ('Build and push openssl-builder image') {
      steps {
        sh "./openssl-builder/build.sh"
      }
    }

    stage ('Build and push builder images') {
      parallel {
        stage ('Build and push phusion-ruby-builder image') {
          steps {
            sh "./phusion-ruby-builder/build.sh"
          }
        }
        stage ('Build and push ubuntu-ruby-builder image') {
          steps {
            sh "./ubuntu-ruby-builder/build.sh"
          }
        }
        stage ('Build and push ubi-ruby-builder image') {
          steps {
            sh "./ubi-ruby-builder/build.sh"
          }
        }
        stage ('Build and tag postgres-client-builder image') {
          steps {
            sh "./postgres-client-builder/build.sh"
          }
        }
        stage ('Build and tag openldap-builder image') {
          steps {
            sh "./phusion-openldap-builder/build.sh"
          }
        }
      }
    }

    stage ('Build, Test, and Scan images') {
      parallel {
        stage ('Build, Test, and Scan phusion-ruby-fips image') {
          steps {
            buildTestAndScanImage('phusion-ruby-fips')
          }
        }
        stage ('Build, Test, and Scan ubuntu-ruby-fips image') {
          steps {
            buildTestAndScanImage('ubuntu-ruby-fips')
          }
        }
        stage ('Build, Test, and Scan ubi-ruby-fips image') {
          steps {
            buildTestAndScanImage('ubi-ruby-fips')
          }
        }
        stage ('Build, Test, and Scan ubi-nginx image') {
          steps {
            buildTestAndScanImage('ubi-nginx')
          }
        }
      }
    }

    stage ('Push internal images') {
      when { branch "main" }

      steps {
        sh "./phusion-ruby-fips/push.sh registry.tld"
        sh "./ubuntu-ruby-fips/push.sh registry.tld"
        sh "./ubi-ruby-fips/push.sh registry.tld"
        sh "./ubi-nginx/push.sh registry.tld"
      }
    }

    stage ('Publish images') {
      when { tag "v*" }

      steps {
        sh "./phusion-ruby-fips/push.sh"
        sh "./ubuntu-ruby-fips/push.sh"
        sh "./ubi-ruby-fips/push.sh"
        sh "./ubi-nginx/push.sh"
      }
    }
  }

  post {
    always {
      archiveArtifacts allowEmptyArchive: true, artifacts: 'test-results/**/*.json', fingerprint: true
      cleanupAndNotify(currentBuild.currentResult, "#development")
    }
  }
}

def buildTestAndScanImage(name) {
  sh "./${name}/build.sh"
  sh "./${name}/test.sh"
  scanAndReport("${name}:latest", "HIGH", false)
  scanAndReport("${name}:latest", "NONE", true)
}
