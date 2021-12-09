pipeline {
  agent { label 'executor-v2' }

  parameters {
    choice(name: 'MODE',
           choices: ["", "BUILD", "RELEASE", "PROMOTE"],
           description: '''Build mode to use:<br>
                           For default behavior, leave blank.<br>
                           To only build, select BUILD.<br>
                           To build and release, choose RELEASE.<br>
                           To promote an existing release, select PROMOTE.''')
    string(name: 'VERSION_TO_PROMOTE', defaultValue: "",
           description: 'Tag version to promote from release to customer release')
  }

  environment {
    MODE = release.canonicalizeMode()
  }

  triggers {
    cron(getDailyCronString())
  }

  stages {
    stage ('Prepare pipeline') {
      steps {
        updateVersion("CHANGELOG.md", "${BUILD_NUMBER}")
      }
    }

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

    stage ('Publish images') {
      when {
        expression {
          MODE == "RELEASE"
        }
      }

      steps {
        release { tag ->
          // Push internal images
          sh "./phusion-ruby-fips/push.sh registry.tld"
          sh "./ubuntu-ruby-fips/push.sh registry.tld"
          sh "./ubi-ruby-fips/push.sh registry.tld"
          sh "./ubi-nginx/push.sh registry.tld"

          // Push Dockerhub images
          sh "./phusion-ruby-fips/push.sh"
          sh "./ubuntu-ruby-fips/push.sh"
          sh "./ubi-ruby-fips/push.sh"
          sh "./ubi-nginx/push.sh"

          // Create BOM for docker images
          sh "mkdir bom/"
          sh """docker-bom -repository "${GIT_URL}" -version "\$(cat VERSION)" > bom/docker.bom.json"""
          archiveArtifacts allowEmptyArchive: true, artifacts: 'bom/*.json', fingerprint: true
        }
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
