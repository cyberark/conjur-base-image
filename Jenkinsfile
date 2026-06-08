@Library([
  'product-pipelines-shared-library',
  'conjur-enterprise-sharedlib@CNJR-13114'
]) _

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
        runSecurityScans(
          image: "registry.tld/cyberark/ubuntu-ruby-fips:${sourceVersion}-arm64",
          arch: 'linux/arm64')
      }
    }

    scans['ubuntu-ruby-fips amd64'] = {
      stage("ubuntu-ruby-fips amd64 scans") {
        runSecurityScans(
          image: "registry.tld/cyberark/ubuntu-ruby-fips:${sourceVersion}-amd64",
          arch: 'linux/amd64')
      }
    }

    scans['ubi-ruby-fips arm64'] = {
      stage("ubi-ruby-fips arm64 scans") {
        runSecurityScans(
          image: "registry.tld/cyberark/ubi-ruby-fips:${sourceVersion}-arm64",
          arch: 'linux/arm64')
      }
    }

    scans['ubi-ruby-fips amd64'] = {
      stage("ubi-ruby-fips amd64 scans") {
        runSecurityScans(
          image: "registry.tld/cyberark/ubi-ruby-fips:${sourceVersion}-amd64",
          arch: 'linux/amd64')
      }
    }

    scans['ubi-nginx amd64'] = {
      stage("ubi-nginx amd64 scans") {
        runSecurityScans(
          image: "registry.tld/conjur-nginx:${sourceVersion}-amd64",
          arch: 'linux/amd64')
      }
    }

    scans['ubi-nginx arm64'] = {
      stage("ubi-nginx arm64 scans") {
        runSecurityScans(
          image: "registry.tld/conjur-nginx:${sourceVersion}-arm64",
          arch: 'linux/arm64')
      }
    }

    parallel(scans)
  }

  // Copy Github Enterprise release to Github
  release.copyEnterpriseRelease(params.VERSION_TO_PROMOTE)
  return
}

pipeline {
  agent { label 'conjur-enterprise-AmznDocker' }

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

    // Pre-allocate InfraPool ARM agent. Runs on AmznDocker (requires aws --profile infrapool).
    // AMD64 build/push runs locally on AmznDocker; arm64 uses InfraPool ExecutorV2ARM.
    stage('Get InfraPool ARM agent') {
      steps {
        script {
          checkout scm
          INFRAPOOL_EXECUTORV2ARM_AGENT_0 = getInfraPoolAgent.connected(type: "ExecutorV2ARM", quantity: 1, duration: 1)[0]
          stash name: 'base_image_infrapool_config', includes: '.infrapool/**', useDefaultExcludes: false
        }
      }
    }

    stage('Mark Workspace as Safe Git Directory') {
      steps {
        script {
          sh "git config --global --add safe.directory $WORKSPACE"
        }
      }
    }

    stage ('Prepare pipeline') {
      steps {
        script {
          updateVersion("CHANGELOG.md", "${BUILD_NUMBER}")
          stash name: 'version_info', includes: 'VERSION'
          unstash 'base_image_infrapool_config'
          load('ci/jenkins/infrapoolSyncVersion.groovy').syncVersionToAgent(INFRAPOOL_EXECUTORV2ARM_AGENT_0)
        }
      }
    }

    stage ('Build and Test images') {
      parallel {
        stage ('ubuntu-ruby-fips arm64 images'){
          steps {
            script {
              prepareArmAgent()
              buildAndTestImageRemote('ubuntu-ruby-fips', INFRAPOOL_EXECUTORV2ARM_AGENT_0)
            }
          }
        }
        stage ('ubi-ruby-fips arm64 images'){
          steps {
            script {
              prepareArmAgent()
              buildAndTestImageRemote('ubi-ruby-fips', INFRAPOOL_EXECUTORV2ARM_AGENT_0)
            }
          }
        }
        stage ('ubi-nginx arm64 images'){
          steps {
            script {
              prepareArmAgent()
              buildAndTestImageRemote('ubi-nginx', INFRAPOOL_EXECUTORV2ARM_AGENT_0)
            }
          }
        }
        stage ('ubuntu-ruby-fips amd64 images'){
          steps {
            script {
              buildAndTestImageLocal('ubuntu-ruby-fips')
            }
          }
        }
        stage ('ubi-ruby-fips amd64 images'){
          steps {
            script {
              buildAndTestImageLocal('ubi-ruby-fips')
            }
          }
        }
        stage ('ubi-nginx amd64 images'){
          steps {
            script {
              buildAndTestImageLocal('ubi-nginx')
            }
          }
        }
      }
    }

    stage('Validate builder on FIPS host') {
      steps {
        script {
          catchError(buildResult: 'SUCCESS', stageResult: 'UNSTABLE') {
            sh 'chmod +x ci/verify-ruby-builder-https.sh ci/verify-builder-bundle-install.sh'
            sh './ci/verify-ruby-builder-https.sh'
            sh './ci/verify-builder-bundle-install.sh'
          }
        }
      }
    }

    stage ('Push architecture specific images to internal registry'){
      parallel {
        stage ('Push arm64 images'){
          steps {
            script {
              prepareArmAgent()
              INFRAPOOL_EXECUTORV2ARM_AGENT_0.agentSh './ubuntu-ruby-fips/push_internal.sh'
              INFRAPOOL_EXECUTORV2ARM_AGENT_0.agentSh './ubi-ruby-fips/push_internal.sh'
              INFRAPOOL_EXECUTORV2ARM_AGENT_0.agentSh './ubi-nginx/push_internal.sh'
            }
          }
        }
        stage ('Push amd64 images'){
          steps {
            script {
              sh './ubuntu-ruby-fips/push_internal.sh'
              sh './ubi-ruby-fips/push_internal.sh'
              sh './ubi-nginx/push_internal.sh'
            }
          }
        }
      }
    }

    stage ('Push manifests to internal registry'){
      steps {
        script {
          sh './ubuntu-ruby-fips/push_multiarch_internal.sh'
          sh './ubi-ruby-fips/push_multiarch_internal.sh'
          sh './ubi-nginx/push_multiarch_internal.sh'
        }
      }
    }

    // This pipeline currently pushes 16 containers (8 ARM64 and 8 AMD64) but we only
    // scan 12 here. It's a conscious choice not to scan the *-slim images here because
    // all their layers are represented in the containers we do scan
    // and thus all issues should be detected. Because we're scanning so many
    // images, however, these are split into 2 groups - the Ubuntu-based images and the
    // UBI-based main images.
    stage ('Run Ubuntu security scans') {
      environment {
        TAG = sh(returnStdout: true, script: 'echo -n "$(<VERSION)"').trim()
        HASH = sh(returnStdout: true, script: 'git log -1 --pretty=format:%h').trim()
        BUILT_VERSION = "${TAG}-${HASH}"
      }
      parallel {
        stage('ubuntu-ruby-builder AMD64 image scans') {
          steps {
            runSecurityScans(
              image: "registry.tld/cyberark/ubuntu-ruby-builder:${BUILT_VERSION}-amd64",
              arch: 'linux/amd64')
          }
        }
        stage('ubuntu-ruby-builder ARM64 image scans') {
          steps {
            runSecurityScans(
              [image: "registry.tld/cyberark/ubuntu-ruby-builder:${BUILT_VERSION}-arm64", arch: 'linux/arm64'],
              INFRAPOOL_EXECUTORV2ARM_AGENT_0)
          }
        }
        stage('ubuntu-ruby-fips AMD64 image scans') {
          steps {
            runSecurityScans(
              image: "registry.tld/cyberark/ubuntu-ruby-fips:${BUILT_VERSION}-amd64",
              arch: 'linux/amd64')
          }
        }
        stage('ubuntu-ruby-fips ARM64 image scans') {
          steps {
            runSecurityScans(
              [image: "registry.tld/cyberark/ubuntu-ruby-fips:${BUILT_VERSION}-arm64", arch: 'linux/arm64'],
              INFRAPOOL_EXECUTORV2ARM_AGENT_0)
          }
        }
        stage('ubuntu-ruby-postgres-fips AMD64 image scans') {
          steps {
            runSecurityScans(
              image: "registry.tld/cyberark/ubuntu-ruby-postgres-fips:${BUILT_VERSION}-amd64",
              arch: 'linux/amd64')
          }
        }
        stage('ubuntu-ruby-postgres-fips ARM64 image scans') {
          steps {
            runSecurityScans(
              [image: "registry.tld/cyberark/ubuntu-ruby-postgres-fips:${BUILT_VERSION}-arm64", arch: 'linux/arm64'],
              INFRAPOOL_EXECUTORV2ARM_AGENT_0)
          }
        }
      }
    }

    stage ('Run UBI security scans') {
      environment {
        TAG = sh(returnStdout: true, script: 'echo -n "$(<VERSION)"').trim()
        HASH = sh(returnStdout: true, script: 'git log -1 --pretty=format:%h').trim()
        BUILT_VERSION = "${TAG}-${HASH}"
      }
      parallel {
        stage('ubi-ruby-builder AMD64 image scans') {
          steps {
            runSecurityScans(
              image: "registry.tld/cyberark/ubi-ruby-builder:${BUILT_VERSION}-amd64",
              arch: 'linux/amd64')
          }
        }
        stage('ubi-ruby-builder ARM64 image scans') {
          steps {
            // When the builder images are pushed, the hash is not added to the
            // label, so just use the TAG value here.
            runSecurityScans(
              [image: "registry.tld/cyberark/ubi-ruby-builder:${BUILT_VERSION}-arm64", arch: 'linux/arm64'],
              INFRAPOOL_EXECUTORV2ARM_AGENT_0)
          }
        }
        stage('ubi-ruby-fips AMD64 image scans') {
          steps {
            runSecurityScans(
              image: "registry.tld/cyberark/ubi-ruby-fips:${BUILT_VERSION}-amd64",
              arch: 'linux/amd64')
          }
        }
        stage('ubi-ruby-fips ARM64 image scans') {
          steps {
            runSecurityScans(
              [image: "registry.tld/cyberark/ubi-ruby-fips:${BUILT_VERSION}-arm64", arch: 'linux/arm64'],
              INFRAPOOL_EXECUTORV2ARM_AGENT_0)
          }
        }
        stage('ubi-nginx AMD64 image scans') {
          steps {
            runSecurityScans(
              image: "registry.tld/conjur-nginx:${BUILT_VERSION}-amd64",
              arch: 'linux/amd64')
          }
        }
        stage('ubi-nginx ARM64 image scans') {
          steps {
            runSecurityScans(
              [image: "registry.tld/conjur-nginx:${BUILT_VERSION}-arm64", arch: 'linux/arm64'],
              INFRAPOOL_EXECUTORV2ARM_AGENT_0)
          }
        }
      }
    }

    // This pipeline currently pushes 16 containers (8 ARM64 and 8 AMD64). It's a
    // conscious choice not to scan the others not listed here because the -slim
    // containers have all their layers represented in the containers we do scan
    // and thus all issues should be detected.
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
              prepareArmAgent()
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
              sh "./ubuntu-ruby-fips/push.sh registry.tld"
              sh "./ubi-ruby-fips/push.sh registry.tld"
              sh "./ubi-nginx/push.sh registry.tld"

              // Push Dockerhub images
              sh "./ubuntu-ruby-fips/push.sh"
              sh "./ubi-ruby-fips/push.sh"
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
          release {
            // Push internal images
            sh "./ubuntu-ruby-fips/push_multiarch.sh registry.tld"
            sh "./ubi-ruby-fips/push_multiarch.sh registry.tld"
            sh "./ubi-nginx/push_multiarch.sh registry.tld"

            // Push Dockerhub images
            sh "./ubuntu-ruby-fips/push_multiarch.sh"
            sh "./ubi-ruby-fips/push_multiarch.sh"
            sh "./ubi-nginx/push.sh"
          }
        }
      }
    }
  }

  post {
    always {
      script {
        try {
          archiveArtifacts allowEmptyArchive: true, artifacts: 'test-results/**/*.xml', fingerprint: true

          def hasArmAgent = binding.hasVariable('INFRAPOOL_EXECUTORV2ARM_AGENT_0') && INFRAPOOL_EXECUTORV2ARM_AGENT_0 != null
          if (hasArmAgent) {
            INFRAPOOL_EXECUTORV2ARM_AGENT_0.agentArchiveArtifacts allowEmptyArchive: true, artifacts: 'test-results/**/*.xml', fingerprint: true
          }

          junit("test-results/**/*.xml")
        } finally {
          releaseInfraPoolAgent(".infrapool/release_agents")
        }
      }
    }
  }
}

def prepareArmAgent() {
  unstash 'base_image_infrapool_config'
  unstash 'version_info'
  load('ci/jenkins/infrapoolSyncVersion.groovy').syncVersionToAgent(INFRAPOOL_EXECUTORV2ARM_AGENT_0)
}

def buildAndTestImageLocal(name) {
  sh "./${name}/build.sh"
  sh "./${name}/test.sh"
}

def buildAndTestImageRemote(name, agent) {
  agent.agentSh "./${name}/build.sh"
  agent.agentSh "./${name}/test.sh"
}
