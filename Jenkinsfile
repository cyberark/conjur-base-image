@Library(['product-pipelines-shared-library', 'conjur-enterprise-sharedlib']) _

def productName = 'Conjur Base Images'
def productTypeName = 'Conjur Enterprise'

// Automated release, promotion and dependencies
properties([
  release.addParams()
])

if (params.MODE == "PROMOTE") {

  release.promote(params.VERSION_TO_PROMOTE) { infrapool, sourceVersion, targetVersion, assetDirectory ->
    env.INFRAPOOL_PRODUCT_NAME = "${productName}"
    env.INFRAPOOL_DD_PRODUCT_TYPE_NAME = "${productTypeName}"

    def scans = [:]

    scans['ubuntu-ruby-fips arm64'] = {
      stage("ubuntu-ruby-fips arm64 scans") {
        runSecurityScans(infrapool,
          image: "registry.tld/cyberark/ubuntu-ruby-fips:${sourceVersion}-arm64",
          arch: 'linux/arm64')
      }
    }

    scans['ubuntu-ruby-fips amd64'] = {
      stage("ubuntu-ruby-fips amd64 scans") {
        runSecurityScans(infrapool,
          image: "registry.tld/cyberark/ubuntu-ruby-fips:${sourceVersion}-amd64",
          arch: 'linux/amd64')
      }
    }

    scans['ubi-ruby-fips arm64'] = {
      stage("ubi-ruby-fips arm64 scans") {
        runSecurityScans(infrapool,
          image: "registry.tld/cyberark/ubi-ruby-fips:${sourceVersion}-arm64",
          arch: 'linux/arm64')
      }
    }

    scans['ubi-ruby-fips amd64'] = {
      stage("ubi-ruby-fips amd64 scans") {
        runSecurityScans(infrapool,
          image: "registry.tld/cyberark/ubi-ruby-fips:${sourceVersion}-amd64",
          arch: 'linux/amd64')
      }
    }

    scans['ubi-nginx amd64'] = {
      stage("ubi-nginx amd64 scans") {
        runSecurityScans(infrapool,
          image: "registry.tld/cyberark/conjur-nginx:${sourceVersion}-amd64",
          arch: 'linux/amd64')
      }
    }

    parallel(scans)
  }

  // Copy Github Enterprise release to Github
  release.copyEnterpriseRelease(params.VERSION_TO_PROMOTE)
  return
}

pipeline {
  agent { label 'conjur-enterprise-common-agent' }

  environment {
    MODE = release.canonicalizeMode()
    INFRAPOOL_PRODUCT_NAME = "${productName}"
    INFRAPOOL_DD_PRODUCT_TYPE_NAME = "${productTypeName}"
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

    stage ('Build and Test images') {
      parallel {
        stage ('ubuntu-ruby-fips arm64 images'){
          steps {
            script {
              buildAndTestImage('ubuntu-ruby-fips', INFRAPOOL_EXECUTORV2ARM_AGENT_0, 'arm64')
            }
          }
        }
        stage ('ubi-ruby-fips arm64 images'){
          steps {
            script {
              buildAndTestImage('ubi-ruby-fips', INFRAPOOL_EXECUTORV2ARM_AGENT_0, 'arm64')
            }
          }
        }
        stage ('ubi-nginx arm64 images'){
          steps {
            script {
              buildAndTestImage('ubi-nginx', INFRAPOOL_EXECUTORV2ARM_AGENT_0, 'arm64')
            }
          }
        }
        stage ('ubuntu-ruby-fips amd64 images'){
          steps {
            script {
              buildAndTestImage('ubuntu-ruby-fips', INFRAPOOL_EXECUTORV2_AGENT_0, 'amd64')
            }
          }
        }
        stage ('ubi-ruby-fips amd64 images'){
          steps {
            script {
              buildAndTestImage('ubi-ruby-fips', INFRAPOOL_EXECUTORV2_AGENT_0, 'amd64')
            }
          }
        }
        stage ('ubi-nginx amd64 images'){
          steps {
            script {
              buildAndTestImage('ubi-nginx', INFRAPOOL_EXECUTORV2_AGENT_0, 'amd64')
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

    stage ('Run security scans') {
      // This pipeline currently pushes 16 containers (8 ARM64 and 8 AMD64). It's a 
      // conscious choice not to scan the others. The ubuntu-ruby-fips-builder and 
      // ubuntu-ruby-postgres-fips containers aren't used anywhere. The -slim containers 
      // have all their layers represented in the containers we do scan and thus all issues
      // should be detected. 
      environment {
        TAG = INFRAPOOL_EXECUTORV2_AGENT_0.agentSh(returnStdout: true, script: 'echo -n "$(<VERSION)"')
        HASH = INFRAPOOL_EXECUTORV2_AGENT_0.agentSh(returnStdout: true, script: 'git log -1 --pretty=format:%h')
        BUILT_VERSION = "${TAG}-${HASH}"
      }
      parallel {
        // ubi-ruby-fips-builder is persisted and reused (in Conjur), so we need to scan it
        stage('ubi-ruby-fips-builder AMD64 image scans') {
          steps {
            runSecurityScans(INFRAPOOL_EXECUTORV2_AGENT_0,
              image: "registry.tld/cyberark/ubi-ruby-fips-builder:${BUILT_VERSION}-amd64",
              arch: 'linux/amd64')
          }
        }

        stage('ubi-ruby-fips-builder ARM64 image scans') {
          steps {
            runSecurityScans(INFRAPOOL_EXECUTORV2ARM_AGENT_0,
              image: "registry.tld/cyberark/ubi-ruby-fips-builder:${BUILT_VERSION}-arm64",
              arch: 'linux/arm64')
          }
        }

        stage('ubuntu-ruby-fips AMD64 image scans') {
          steps {
            runSecurityScans(INFRAPOOL_EXECUTORV2_AGENT_0,
              image: "registry.tld/cyberark/ubuntu-ruby-fips:${BUILT_VERSION}-amd64",
              arch: 'linux/amd64')
          }
        }

        stage('ubuntu-ruby-fips ARM64 image scans') {
          steps {
            runSecurityScans(INFRAPOOL_EXECUTORV2ARM_AGENT_0,
              image: "registry.tld/cyberark/ubuntu-ruby-fips:${BUILT_VERSION}-arm64",
              arch: 'linux/arm64')
          }
        }

        stage('ubi-ruby-fips AMD64 image scans') {
          steps {
            runSecurityScans(INFRAPOOL_EXECUTORV2_AGENT_0,
              image: "registry.tld/cyberark/ubi-ruby-fips:${BUILT_VERSION}-amd64",
              arch: 'linux/amd64')
          }
        }

        stage('ubi-ruby-fips ARM64 image scans') {
          steps {
            runSecurityScans(INFRAPOOL_EXECUTORV2ARM_AGENT_0,
              image: "registry.tld/cyberark/ubi-ruby-fips:${BUILT_VERSION}-arm64",
              arch: 'linux/arm64')
          }
        }
        stage('ubi-nginx AMD64 image scans') {
          steps {
            runSecurityScans(INFRAPOOL_EXECUTORV2_AGENT_0,
              image: "registry.tld/conjur-nginx:${BUILT_VERSION}-amd64",
              arch: 'linux/amd64')
          }
        }
        stage('ubi-nginx ARM64 image scans') {
          steps {
            runSecurityScans(INFRAPOOL_EXECUTORV2_AGENT_0,
              image: "registry.tld/conjur-nginx:${BUILT_VERSION}-arm64",
              arch: 'linux/arm64')
          }
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
        junit("test-results/**/*.xml")
        releaseInfraPoolAgent(".infrapool/release_agents")
      }
    }
  }
}

def buildAndTestImage(name, def agent, arch) {
  agent.agentSh "./${name}/build.sh"
  agent.agentSh "./${name}/test.sh"
}
