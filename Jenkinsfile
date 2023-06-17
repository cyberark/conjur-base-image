// Automated release, promotion and dependencies
properties([
  release.addParams()
])

if (params.MODE == "PROMOTE") {
  release.promote(params.VERSION_TO_PROMOTE) { sourceVersion, targetVersion, assetDirectory ->
    // Nothing to do here except the promote() automation itself
  }

  // Copy Github Enterprise release to Github
  release.copyEnterpriseRelease(params.VERSION_TO_PROMOTE)
  return
}

pipeline {
  agent { label 'conjur-enterprise-common-agent' }

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

    stage('Get InfraPool ExecutorV2 Agent') {
      steps {
        script {
          // Request ExecutorV2 agents for 1 hour(s)
          INFRAPOOL_EXECUTORV2_AGENT_0 = getInfraPoolAgent.connected(type: "ExecutorV2", quantity: 1, duration: 1)[0]
        }
      }
    }

    stage ('Prepare pipeline') {
      steps {
        script {
          updateVersion(INFRAPOOL_EXECUTORV2_AGENT_0, "CHANGELOG.md", "${BUILD_NUMBER}")
        }
      }
    }

    stage ('Build, Test, and Scan images') {
      parallel {
        stage ('Build, Test, and Scan ubuntu-ruby-fips image') {
          steps {
            script {
              buildTestAndScanImage('ubuntu-ruby-fips')
            }
          }
        }
        stage ('Build, Test, and Scan ubi-ruby-fips image') {
          steps {
            script {
              buildTestAndScanImage('ubi-ruby-fips')
            }
          }
        }
        stage ('Build, Test, and Scan ubi-nginx image') {
          steps {
            script {
              buildTestAndScanImage('ubi-nginx')
            }
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
        script {
          release(INFRAPOOL_EXECUTORV2_AGENT_0) {
            // Push internal images
            INFRAPOOL_EXECUTORV2_AGENT_0.agentSh "./phusion-ruby-fips/push.sh registry.tld"
            INFRAPOOL_EXECUTORV2_AGENT_0.agentSh "./ubuntu-ruby-fips/push.sh registry.tld"
            INFRAPOOL_EXECUTORV2_AGENT_0.agentSh "./ubi-ruby-fips/push.sh registry.tld"
            INFRAPOOL_EXECUTORV2_AGENT_0.agentSh "./ubi-nginx/push.sh registry.tld"

            // Push Dockerhub images
            INFRAPOOL_EXECUTORV2_AGENT_0.agentSh "./phusion-ruby-fips/push.sh"
            INFRAPOOL_EXECUTORV2_AGENT_0.agentSh "./ubuntu-ruby-fips/push.sh"
            INFRAPOOL_EXECUTORV2_AGENT_0.agentSh "./ubi-ruby-fips/push.sh"
            INFRAPOOL_EXECUTORV2_AGENT_0.agentSh "./ubi-nginx/push.sh"
          }
        }
      }
    }
  }

  post {
    always {
      script {
        INFRAPOOL_EXECUTORV2_AGENT_0.agentArchiveArtifacts allowEmptyArchive: true, artifacts: 'test-results/**/*.json', fingerprint: true
        releaseInfraPoolAgent(".infrapool/release_agents")
      }
    }
  }
}

def buildTestAndScanImage(name) {
  INFRAPOOL_EXECUTORV2_AGENT_0.agentSh "./${name}/build.sh"
  INFRAPOOL_EXECUTORV2_AGENT_0.agentSh "./${name}/test.sh"
  scanAndReport(INFRAPOOL_EXECUTORV2_AGENT_0, "${name}:latest", "HIGH", false)
  scanAndReport(INFRAPOOL_EXECUTORV2_AGENT_0, "${name}:latest", "NONE", true)
}
