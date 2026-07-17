@Library([
  'product-pipelines-shared-library',
  'conjur-enterprise-sharedlib'
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
        retry(3) {
          runSecurityScans(
            image: "registry.tld/cyberark/ubuntu-ruby-fips:${sourceVersion}-arm64",
            arch: 'linux/arm64')
        }
      }
    }

    scans['ubuntu-ruby-fips amd64'] = {
      stage("ubuntu-ruby-fips amd64 scans") {
        retry(3) {
          runSecurityScans(
            image: "registry.tld/cyberark/ubuntu-ruby-fips:${sourceVersion}-amd64",
            arch: 'linux/amd64')
        }
      }
    }

    scans['ubi-ruby-fips arm64'] = {
      stage("ubi-ruby-fips arm64 scans") {
        retry(3) {
          runSecurityScans(
            image: "registry.tld/cyberark/ubi-ruby-fips:${sourceVersion}-arm64",
            arch: 'linux/arm64')
        }
      }
    }

    scans['ubi-ruby-fips amd64'] = {
      stage("ubi-ruby-fips amd64 scans") {
        retry(3) {
          runSecurityScans(
            image: "registry.tld/cyberark/ubi-ruby-fips:${sourceVersion}-amd64",
            arch: 'linux/amd64')
        }
      }
    }

    scans['ubi-nginx amd64'] = {
      stage("ubi-nginx amd64 scans") {
        retry(3) {
          runSecurityScans(
            image: "registry.tld/conjur-nginx:${sourceVersion}-amd64",
            arch: 'linux/amd64')
        }
      }
    }

    scans['ubi-nginx arm64'] = {
      stage("ubi-nginx arm64 scans") {
        retry(3) {
          runSecurityScans(
            image: "registry.tld/conjur-nginx:${sourceVersion}-arm64",
            arch: 'linux/arm64')
        }
      }
    }

    stage('Parallel Stage') {
      parallel(scans + [failFast: true])
    }
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

    // CI on AmznDocker (CNJR-13114): orchestrator + 1 amd64 worker (ExecutorV2 equivalent).
    // See docs/building-on-fips-enabled-hosts.md for FIPS-host build notes and agent topology.
    // arm64 uses InfraPool ExecutorV2ARM (quantity 1) via agentSh on the orchestrator.
    stage('Get InfraPool ARM agent') {
      steps {
        script {
          checkout scm
          INFRAPOOL_EXECUTORV2ARM_AGENT_0 = getInfraPoolAgent.connected(type: "ExecutorV2ARM", quantity: 1, duration: 2)[0]
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
          sh 'git rev-parse --short HEAD > GIT_SHA'
          stash name: 'version_info', includes: 'VERSION,GIT_SHA'
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
        stage ('amd64 images'){
          steps {
            script {
              buildAndTestAmd64Images()
            }
          }
        }
      }
    }

    // amd64 internal push runs on the build worker (buildAndTestAmd64Images) before the
    // ephemeral EC2 terminates; only arm64 push uses ExecutorV2ARM here.
    stage ('Push arm64 images to internal registry'){
      steps {
        script {
          prepareArmAgent()
          retry(3) { INFRAPOOL_EXECUTORV2ARM_AGENT_0.agentSh './ubuntu-ruby-fips/push_internal.sh' }
          retry(3) { INFRAPOOL_EXECUTORV2ARM_AGENT_0.agentSh './ubi-ruby-fips/push_internal.sh' }
          retry(3) { INFRAPOOL_EXECUTORV2ARM_AGENT_0.agentSh './ubi-nginx/push_internal.sh' }
        }
      }
    }

    stage ('Push manifests to internal registry'){
      steps {
        script {
          retry(3) { sh './ubuntu-ruby-fips/push_multiarch_internal.sh' }
          retry(3) { sh './ubi-ruby-fips/push_multiarch_internal.sh' }
          retry(3) { sh './ubi-nginx/push_multiarch_internal.sh' }
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
      steps {
        script {
          def builtVersion = computeBuiltVersion()
          parallel(
            'ubuntu-ruby-builder AMD64 image scans': {
              runAmd64SecurityScan(
                image: "registry.tld/cyberark/ubuntu-ruby-builder:${builtVersion}-amd64",
                arch: 'linux/amd64')
            },
            'ubuntu-ruby-builder ARM64 image scans': {
              retry(3) {
                runSecurityScans(
                  [image: "registry.tld/cyberark/ubuntu-ruby-builder:${builtVersion}-arm64", arch: 'linux/arm64'],
                  INFRAPOOL_EXECUTORV2ARM_AGENT_0)
              }
            },
            'ubuntu-ruby-fips AMD64 image scans': {
              runAmd64SecurityScan(
                image: "registry.tld/cyberark/ubuntu-ruby-fips:${builtVersion}-amd64",
                arch: 'linux/amd64')
            },
            'ubuntu-ruby-fips ARM64 image scans': {
              retry(3) {
                runSecurityScans(
                  [image: "registry.tld/cyberark/ubuntu-ruby-fips:${builtVersion}-arm64", arch: 'linux/arm64'],
                  INFRAPOOL_EXECUTORV2ARM_AGENT_0)
              }
            },
            'ubuntu-ruby-postgres-fips AMD64 image scans': {
              runAmd64SecurityScan(
                image: "registry.tld/cyberark/ubuntu-ruby-postgres-fips:${builtVersion}-amd64",
                arch: 'linux/amd64')
            },
            'ubuntu-ruby-postgres-fips ARM64 image scans': {
              retry(3) {
                runSecurityScans(
                  [image: "registry.tld/cyberark/ubuntu-ruby-postgres-fips:${builtVersion}-arm64", arch: 'linux/arm64'],
                  INFRAPOOL_EXECUTORV2ARM_AGENT_0)
              }
            }
          )
        }
      }
    }

    stage ('Run UBI security scans') {
      steps {
        script {
          def builtVersion = computeBuiltVersion()
          parallel(
            'ubi-ruby-builder AMD64 image scans': {
              runAmd64SecurityScan(
                image: "registry.tld/cyberark/ubi-ruby-builder:${builtVersion}-amd64",
                arch: 'linux/amd64')
            },
            'ubi-ruby-builder ARM64 image scans': {
              // When the builder images are pushed, the hash is not added to the
              // label, so just use the TAG value here.
              retry(3) {
                runSecurityScans(
                  [image: "registry.tld/cyberark/ubi-ruby-builder:${builtVersion}-arm64", arch: 'linux/arm64'],
                  INFRAPOOL_EXECUTORV2ARM_AGENT_0)
              }
            },
            'ubi-ruby-fips AMD64 image scans': {
              runAmd64SecurityScan(
                image: "registry.tld/cyberark/ubi-ruby-fips:${builtVersion}-amd64",
                arch: 'linux/amd64')
            },
            'ubi-ruby-fips ARM64 image scans': {
              retry(3) {
                runSecurityScans(
                  [image: "registry.tld/cyberark/ubi-ruby-fips:${builtVersion}-arm64", arch: 'linux/arm64'],
                  INFRAPOOL_EXECUTORV2ARM_AGENT_0)
              }
            },
            'ubi-nginx AMD64 image scans': {
              runAmd64SecurityScan(
                image: "registry.tld/conjur-nginx:${builtVersion}-amd64",
                arch: 'linux/amd64')
            },
            'ubi-nginx ARM64 image scans': {
              retry(3) {
                runSecurityScans(
                  [image: "registry.tld/conjur-nginx:${builtVersion}-arm64", arch: 'linux/arm64'],
                  INFRAPOOL_EXECUTORV2ARM_AGENT_0)
              }
            }
          )
        }
      }
    }

    stage('Archive arm64 test results') {
      steps {
        script {
          def hasArmAgent = binding.hasVariable('INFRAPOOL_EXECUTORV2ARM_AGENT_0') && INFRAPOOL_EXECUTORV2ARM_AGENT_0 != null
          if (hasArmAgent) {
            catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
              INFRAPOOL_EXECUTORV2ARM_AGENT_0.agentArchiveArtifacts allowEmptyArchive: true, artifacts: 'test-results/**/*.xml', fingerprint: true
              junit allowEmptyResults: true, testResults: 'test-results/**/*.xml'
            }
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
              retry(3) { INFRAPOOL_EXECUTORV2ARM_AGENT_0.agentSh "./ubuntu-ruby-fips/push.sh registry.tld" }
              retry(3) { INFRAPOOL_EXECUTORV2ARM_AGENT_0.agentSh "./ubi-ruby-fips/push.sh registry.tld" }
              retry(3) { INFRAPOOL_EXECUTORV2ARM_AGENT_0.agentSh "./ubi-nginx/push.sh registry.tld" }
              INFRAPOOL_EXECUTORV2ARM_AGENT_0.agentSh "./ubuntu-ruby-fips/push.sh"
              INFRAPOOL_EXECUTORV2ARM_AGENT_0.agentSh "./ubi-ruby-fips/push.sh"
            }
          }
        }
        stage ('Push amd64 images'){
          steps {
            script {
              publishAmd64ReleaseImages()
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
            retry(3) { sh "./ubuntu-ruby-fips/push_multiarch.sh registry.tld" }
            retry(3) { sh "./ubi-ruby-fips/push_multiarch.sh registry.tld" }
            retry(3) { sh "./ubi-nginx/push_multiarch.sh registry.tld" }

            // Push Dockerhub images (ubi-nginx quay push runs on amd64 worker in publishAmd64ReleaseImages)
            sh "./ubuntu-ruby-fips/push_multiarch.sh"
            sh "./ubi-ruby-fips/push_multiarch.sh"
          }
        }
      }
    }
  }

  post {
    always {
      script {
        releaseInfraPoolAgent(".infrapool/release_agents")
      }
    }
  }
}

def computeBuiltVersion() {
  return "${readFile('VERSION').trim()}-${readFile('GIT_SHA').trim()}"
}

def runAmd64SecurityScan(Map scanParams) {
  node('conjur-enterprise-AmznDocker') {
    checkout scm
    unstash 'version_info'
    retry(3) {
      runSecurityScans(scanParams)
    }
  }
}

def prepareArmAgent() {
  unstash 'base_image_infrapool_config'
  unstash 'version_info'
  load('ci/jenkins/infrapoolSyncVersion.groovy').syncVersionToAgent(INFRAPOOL_EXECUTORV2ARM_AGENT_0)
}

def buildAndTestImageRemote(name, agent) {
  agent.agentSh "./${name}/build.sh"
  agent.agentSh "./${name}/test.sh"
}

def buildAndTestAmd64Images() {
  node('conjur-enterprise-AmznDocker') {
    checkout scm
    unstash 'version_info'
    parallel(
      'ubuntu-ruby-fips amd64 images': {
        retry(3) { sh './ubuntu-ruby-fips/build.sh' }
        sh './ubuntu-ruby-fips/test.sh'
        archiveArtifacts allowEmptyArchive: true, artifacts: 'test-results/**/*', fingerprint: true
        junit allowEmptyResults: true, testResults: 'test-results/**/*.xml'
      },
      'ubi-ruby-fips amd64 images': {
        retry(3) { sh './ubi-ruby-fips/build.sh' }
        sh './ubi-ruby-fips/test.sh'
        archiveArtifacts allowEmptyArchive: true, artifacts: 'test-results/**/*', fingerprint: true
        junit allowEmptyResults: true, testResults: 'test-results/**/*.xml'
      },
      'ubi-nginx amd64 images': {
        retry(3) { sh './ubi-nginx/build.sh' }
        sh './ubi-nginx/test.sh'
        archiveArtifacts allowEmptyArchive: true, artifacts: 'test-results/**/*', fingerprint: true
        junit allowEmptyResults: true, testResults: 'test-results/**/*.xml'
      }
    )
    // Push before this ephemeral worker terminates; images are not available on a fresh node().
    retry(3) { sh './ubuntu-ruby-fips/push_internal.sh' }
    retry(3) { sh './ubi-ruby-fips/push_internal.sh' }
    retry(3) { sh './ubi-nginx/push_internal.sh' }
  }
}

def publishAmd64ReleaseImages() {
  node('conjur-enterprise-AmznDocker') {
    checkout scm
    unstash 'version_info'
    sh 'chmod +x ci/pull-amd64-for-release.sh && ./ci/pull-amd64-for-release.sh'
    retry(3) { sh './ubuntu-ruby-fips/push.sh registry.tld' }
    retry(3) { sh './ubi-ruby-fips/push.sh registry.tld' }
    retry(3) { sh './ubi-nginx/push.sh registry.tld' }
    sh './ubuntu-ruby-fips/push.sh'
    sh './ubi-ruby-fips/push.sh'
    // quay.io: needs local ubi-nginx:latest-amd64 from pull-amd64-for-release.sh above
    sh './ubi-nginx/push.sh'
  }
}
