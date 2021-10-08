pipeline {
  agent { label 'executor-v2' }

  triggers {
    cron(getDailyCronString())
  }

  environment {
    DEV_CHANNEL = getDevelopmentChannel(env.BRANCH_NAME)
    CHANNEL_TAGS = getTags(env.DEV_CHANNEL)
  }

  stages {
    stage ('Build and push openssl-builder image') {
      steps {
        buildImage("openssl-builder", '${OPENSSL_BUILDER_TAG}', "OPENSSL_VER OPENSSL_FIPS_VER")
      }
    }

    stage ('Build and push builder images') {
      parallel {
        stage ('Build and push phusion-ruby-builder image') {
          steps {
            buildImage("phusion-ruby-builder", '${RUBY_BUILDER_TAG}', "PHUSION_VERSION RUBY_MAJOR_VERSION RUBY_FULL_VERSION OPENSSL_BUILDER_TAG")
          }
        }
        stage ('Build and push ubuntu-ruby-builder image') {
          steps {
            buildImage("ubuntu-ruby-builder", '${RUBY_BUILDER_TAG}', "UBUNTU_VERSION RUBY_MAJOR_VERSION RUBY_FULL_VERSION OPENSSL_BUILDER_TAG")
          }
        }
        stage ('Build and push ubi-ruby-builder image') {
          steps {
            buildImage("ubi-ruby-builder", '${RUBY_BUILDER_TAG}', "UBI_VERSION RUBY_MAJOR_VERSION RUBY_FULL_VERSION")
          }
        }
        stage ('Build and tag postgres-client-builder image') {
          steps {
            buildImage("postgres-client-builder", '${PG_BUILDER_TAG}', "PG_VERSION OPENSSL_BUILDER_TAG")
          }
        }
        stage ('Build and tag openldap-builder image') {
          steps {
            buildImage("phusion-openldap-builder", '${OPENLDAP_BUILDER_TAG}', "PHUSION_VERSION OPENLDAP_VERSION OPENSSL_BUILDER_TAG")
          }
        }
      }
    }

    stage ('Build, Test, and Scan images') {
      parallel {
        stage ('Build, Test, and Scan phusion-ruby-fips image') {
          steps {
            buildImage("phusion-ruby-fips", 'latest', "PHUSION_VERSION OPENSSL_BUILDER_TAG RUBY_BUILDER_TAG PG_BUILDER_TAG OPENLDAP_BUILDER_TAG")
            testAndScanImage('phusion-ruby-fips')
          }
        }
        stage ('Build, Test, and Scan ubuntu-ruby-fips image') {
          steps {
            buildImage("ubuntu-ruby-fips", 'latest', "PHUSION_VERSION UBUNTU_VERSION OPENSSL_BUILDER_TAG RUBY_BUILDER_TAG PG_BUILDER_TAG OPENLDAP_BUILDER_TAG")
            testAndScanImage('ubuntu-ruby-fips')
          }
        }
        stage ('Build, Test, and Scan ubi-ruby-fips image') {
          steps {
            buildImage("ubi-ruby-fips", 'latest', "UBI_VERSION RUBY_BUILDER_TAG")
            testAndScanImage('ubi-ruby-fips')
          }
        }
        stage ('Build, Test, and Scan ubi-nginx image') {
          steps {
            buildImage("ubi-nginx", 'latest', "NGINX_VERSION")
            testAndScanImage('ubi-nginx')
          }
        }
      }
    }

    // Internal images are always pushed to channel tags
    stage ('Push internal images') {
      steps {
        sh "./phusion-ruby-fips/push registry.tld"
        sh "./ubuntu-ruby-fips/push registry.tld"
        sh "./ubi-ruby-fips/push registry.tld"
        sh "./ubi-nginx/push registry.tld"
      }
    }

    // DockerHub images are pushed for edge or latest channels
    // If this is a tagged build, the push scripts will included tagged build versions
    stage ('Publish DockerHub images') {
      when {
        expression { env.DEV_CHANNEL ==~ /(edge|latest)/ }
      }

      steps {
        sh "./phusion-ruby-fips/push"
        sh "./ubuntu-ruby-fips/push"
        sh "./ubi-ruby-fips/push"
        sh "./ubi-nginx/push"
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

def buildImage(name, tag, params) {
  sh ". build.env && ./build ${name} ${tag} ${params}"
}

def testAndScanImage(name) {
  sh "./${name}/test"
  scanAndReport("${name}:latest", "HIGH", false)
  scanAndReport("${name}:latest", "NONE", true)
}

// Determine the development channel the project should push to and pull internal dependencies from.
def getDevelopmentChannel(branch) {
  if (["master", "main"].contains(branch)) {
    return "edge"
  }

  if (branch.startsWith("release/")) {
    return "latest"
  }

  return branch
}

// Convert a git branch name into a valid docker tag.
// This is done by replacing all invalid characters with underscores.  Note that this means that it's not possible
// to programmatically go from docker tag -> git branch in pessimal cases, but a person should have no difficulty
// recognizing the correct one.
//
// From https://docs.docker.com/engine/reference/commandline/tag/
// A tag name must be valid ASCII and may contain lowercase and uppercase letters, digits, underscores, periods and
// dashes. A tag name may not start with a period or a dash and may contain a maximum of 128 characters.
def safeEncodeBranchToDockerTag(branch) {
  // Git tags can not start with periods or dashes, so simplify by only looking at invalid characters in the full tag
  return branch.replaceAll(/[^0-9a-zA-Z_.-]/, "_")
}

// Determine the channel specific tags that should be pushed to.  These are separate from (but related to) specific
// version tags.  Returns as a space separated string for easy processing/use in scripts.
//
// <channel> - <tags>
// latest    - <release_branch_name>-<8 digit commit hash>, latest, latest-<8 digit commit hash>
// edge      - edge, edge-<8 digit commit hash>
// <branch>  - <encoded_branch_name>, <encoded_branch_name>-<8 digit commit hash>
def getTags(channel) {
  def result = []
  def commit = sh(returnStdout: true, script: "git rev-parse --short=8 HEAD | tr -d '\n'")

  switch(channel) {
    case "latest":
      def branch_version = safeEncodeBranchToDockerTag(env.BRANCH_NAME.split('release/')[1])
      result.add("latest")
      result.add("latest-${commit}")
      result.add("${branch_version}-${commit}")
      break
    case "edge":
      result.add("edge")
      result.add("edge-${commit}")
      break
    default:
      def docker_safe_branch = safeEncodeBranchToDockerTag(env.BRANCH_NAME)
      result.add(docker_safe_branch)
      result.add("${docker_safe_branch}-${commit}")
  }

  return result.join(" ")
}