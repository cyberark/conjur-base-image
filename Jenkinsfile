// Automated release, promotion and dependencies
properties([
  release.addParams()
])

if (params.MODE == "PROMOTE") {
  release.promote(params.VERSION_TO_PROMOTE) { sourceVersion, targetVersion, assetDirectory ->
    // Nothing to do here except the promote() automation itself
  }
  return
}

pipeline {
  agent { label 'executor-v2' }

  environment {
    MODE = release.canonicalizeMode()
  }

  triggers {
    parameterizedCron(getDailyCronString("%MODE=RELEASE"))
  }

  stages {
    stage ("Skip build if triggering job didn't create a release") {
      when {
        expression {
          MODE == "SKIP"
        }
      }
      steps {
        script {
          currentBuild.result = 'ABORTED'
          error("Aborting build because this build was triggered from upstream, but no release was built")
        }
      }
    }

    stage ('Prepare pipeline') {
      steps {
        updateVersion("CHANGELOG.md", "${BUILD_NUMBER}")
      }
    }

    stage ('Build, Test, and Scan images') {
      parallel {
        stage ('Build, Test, and Scan ubuntu-ruby-fips image') {
          steps {
            sh "docker buildx ls"
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

    stage ('Publish experimental images to internal repository') {
      steps {
        sh "./ubi-ruby-fips/push_experimental.sh registry.tld"
        sh "./ubuntu-ruby-fips/push_experimental.sh registry.tld"
      }
    }

    stage ('Publish images') {
      when {
        expression {
          MODE == "RELEASE"
        }
      }

      steps {
        release {
          // Push internal images
          sh "./ubuntu-ruby-fips/push.sh registry.tld"
          sh "./ubi-ruby-fips/push.sh registry.tld"
          sh "./ubi-nginx/push.sh registry.tld"

          // Push Dockerhub images
          sh "./ubuntu-ruby-fips/push.sh"
          sh "./ubi-ruby-fips/push.sh"
          sh "./ubi-nginx/push.sh"
        }
      }
    }
  }

  post {
    always {
      archiveArtifacts allowEmptyArchive: true, artifacts: 'test-results/**/*.xml', fingerprint: true
      junit 'test-results/**/*.xml'
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
