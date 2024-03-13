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

    stage('Scan for internal URLs') {
      steps {
        script {
          detectInternalUrls()
        }
      }
    }

    stage('Get InfraPool ExecutorV2 Agent') {
      steps {
        script {
          // Request ExecutorV2 agents for 1 hour(s)
          INFRAPOOL_EXECUTORV2_AGENT_0 = getInfraPoolAgent.connected(type: "ExecutorV2", quantity: 1, duration: 1)[0]
          INFRAPOOL_EXECUTORV2ARM_AGENT_0 = getInfraPoolAgent.connected(type: "ExecutorV2ARM", quantity: 1, duration: 1)[0]
        }
      }
    }

    stage ('Prepare pipeline') {
      steps {
        script {
          updateVersion(INFRAPOOL_EXECUTORV2_AGENT_0, "CHANGELOG.md", "${BUILD_NUMBER}")
          updateVersion(INFRAPOOL_EXECUTORV2ARM_AGENT_0, "CHANGELOG.md", "${BUILD_NUMBER}")
        }
      }
    }
    stage ('Build, Test, and Scan images') {
      parallel {
        stage ('ubuntu-ruby-fips arm64 images'){
          steps {
            script {
              buildTestAndScanImage('ubuntu-ruby-fips', INFRAPOOL_EXECUTORV2ARM_AGENT_0, 'arm64')
            }
          }
        }
        stage ('ubi-ruby-fips arm64 images'){
          steps {
            script {
              buildTestAndScanImage('ubi-ruby-fips', INFRAPOOL_EXECUTORV2ARM_AGENT_0, 'arm64')
            }
          }
        }
        stage ('ubi-nginx arm64 images'){
          steps {
            script {
              buildTestAndScanImage('ubi-nginx', INFRAPOOL_EXECUTORV2ARM_AGENT_0, 'arm64')
            }
          }
        }
        stage ('ubuntu-ruby-fips amd64 images'){
          steps {
            script {
              buildTestAndScanImage('ubuntu-ruby-fips', INFRAPOOL_EXECUTORV2_AGENT_0, 'amd64')
            }
          }
        }
        stage ('ubi-ruby-fips amd64 images'){
          steps {
            script {
              buildTestAndScanImage('ubi-ruby-fips', INFRAPOOL_EXECUTORV2_AGENT_0, 'amd64')
            }
          }
        }
        stage ('ubi-nginx amd64 images'){
          steps {
            script {
              buildTestAndScanImage('ubi-nginx', INFRAPOOL_EXECUTORV2_AGENT_0, 'amd64')
            }
          }
        }
      }
    }

    stage ('Push architecture specific images to internal registry'){
      parallel {
        stage ('Push arm64 images'){
          steps {
            script {
              INFRAPOOL_EXECUTORV2ARM_AGENT_0.agentSh './ubuntu-ruby-fips/push_internal.sh'
              INFRAPOOL_EXECUTORV2ARM_AGENT_0.agentSh './ubi-ruby-fips/push_internal.sh'
              INFRAPOOL_EXECUTORV2ARM_AGENT_0.agentSh './ubi-nginx/push_internal.sh'
            }
          }
        }
        stage ('Push amd64 images'){
          steps {
            script {
              INFRAPOOL_EXECUTORV2_AGENT_0.agentSh './ubuntu-ruby-fips/push_internal.sh'
              INFRAPOOL_EXECUTORV2_AGENT_0.agentSh './ubi-ruby-fips/push_internal.sh'
              INFRAPOOL_EXECUTORV2_AGENT_0.agentSh './ubi-nginx/push_internal.sh'
            }
          }
        }
      }
    }

    stage ('Push manifests to internal registry'){
      steps {
        script {
          INFRAPOOL_EXECUTORV2_AGENT_0.agentSh './ubuntu-ruby-fips/push_multiarch_internal.sh'
          INFRAPOOL_EXECUTORV2_AGENT_0.agentSh './ubi-ruby-fips/push_multiarch_internal.sh'
          INFRAPOOL_EXECUTORV2_AGENT_0.agentSh './ubi-nginx/push_multiarch_internal.sh'
        }
      }
    }

    stage ('Publish latest arch specific images'){
      when {
        expression {
          MODE == "RELEASE"
        }
      }
      parallel {
        stage ('Push arm64 images'){
          steps {
            script {
              // Push internal images
              INFRAPOOL_EXECUTORV2ARM_AGENT_0.agentSh "./ubuntu-ruby-fips/push.sh registry.tld"
              INFRAPOOL_EXECUTORV2ARM_AGENT_0.agentSh "./ubi-ruby-fips/push.sh registry.tld"
              INFRAPOOL_EXECUTORV2ARM_AGENT_0.agentSh "./ubi-nginx/push.sh registry.tld"

              // Push Dockerhub images
              INFRAPOOL_EXECUTORV2ARM_AGENT_0.agentSh "./ubuntu-ruby-fips/push.sh"
              INFRAPOOL_EXECUTORV2ARM_AGENT_0.agentSh "./ubi-ruby-fips/push.sh"
            }
          }
        }
        stage ('Push amd64 images'){
          steps {
            script {
              // Push internal images
              INFRAPOOL_EXECUTORV2_AGENT_0.agentSh "./ubuntu-ruby-fips/push.sh registry.tld"
              INFRAPOOL_EXECUTORV2_AGENT_0.agentSh "./ubi-ruby-fips/push.sh registry.tld"
              INFRAPOOL_EXECUTORV2_AGENT_0.agentSh "./ubi-nginx/push.sh registry.tld"

              // Push Dockerhub images
              INFRAPOOL_EXECUTORV2_AGENT_0.agentSh "./ubuntu-ruby-fips/push.sh"
              INFRAPOOL_EXECUTORV2_AGENT_0.agentSh "./ubi-ruby-fips/push.sh"
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
            INFRAPOOL_EXECUTORV2_AGENT_0.agentSh "./ubuntu-ruby-fips/push_multiarch.sh registry.tld"
            INFRAPOOL_EXECUTORV2_AGENT_0.agentSh "./ubi-ruby-fips/push_multiarch.sh registry.tld"
            INFRAPOOL_EXECUTORV2_AGENT_0.agentSh "./ubi-nginx/push_multiarch.sh registry.tld"

            // Push Dockerhub images
            INFRAPOOL_EXECUTORV2_AGENT_0.agentSh "./ubuntu-ruby-fips/push_multiarch.sh"
            INFRAPOOL_EXECUTORV2_AGENT_0.agentSh "./ubi-ruby-fips/push_multiarch.sh"
            INFRAPOOL_EXECUTORV2_AGENT_0.agentSh "./ubi-nginx/push.sh"
          }
        }
      }
    }
  }

  post {
    always {
      script {
        INFRAPOOL_EXECUTORV2_AGENT_0.agentArchiveArtifacts allowEmptyArchive: true, artifacts: 'test-results/**/*.xml', fingerprint: true
        releaseInfraPoolAgent(".infrapool/release_agents")
      }
    }
  }
}

def buildTestAndScanImage(name, def agent, arch) {
  agent.agentSh "./${name}/build.sh"
  agent.agentSh "./${name}/test.sh"
  scanAndReport(agent, "${name}:latest-${arch}", "HIGH", false)
  scanAndReport(agent, "${name}:latest-${arch}", "NONE", true)
}