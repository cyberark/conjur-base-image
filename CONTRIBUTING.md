# Contributing to the Conjur base image

Thanks for your interest in the Conjur base image. We welcome contributions!


For general contribution and community guidelines, please see the [community repo](https://github.com/cyberark/community).

## Table of Contents

- [Prerequisites](#prerequisites)
- [Contributing](#contributing)
- [Development](#development)
- [Testing](#testing)
  - [Security testing ](#security-testing )
- [Releasing](#releasing)


## Prerequisites

Before getting started, you should install some developer tools. 

1. [git][get-git] to manage source code
1. [Docker][get-docker] to manage dependencies and runtime environments

[get-docker]: https://docs.docker.com/engine/installation
[get-git]: https://git-scm.com/downloads

## Contributing

### Contributing workflow

1. Search our [open issues](https://github.com/cyberark/conjur-base-image/issues) in GitHub to see what features are planned.

1. Select an existing issue or open a new issue to propose changes or fixes.

1. Add the `implementing` label to the issue that you open or modify.

1. Run [existing tests](#testing) locally and ensure they pass.

1. Create a branch and add your changes. Include appropriate tests and ensure that they pass.

1. Ensure the [changelog](CHANGELOG.md) contains all relevant recent changes with references to GitHub issues or PRs, if possible.

1. Submit a pull request, linking the issue in the description (e.g. Connected to #123).

1. Add the `implemented` label to the issue and request that a Cyberark engineer reviews and merges your code.

From here your pull request is reviewed. Once you have implemented all reviewer feedback, your code is merged into the project. Congratulations, you're a contributor!

## Development

It's easy to get started with Conjur base image

1. [Install dependencies](#Prerequisites)

1. Clone this repository

To build Ubuntu base image:
   ```sh-session
   $ cd dev
   $ ./ubuntu-ruby-fips.sh
   ```
To build Phusion base image:
   ```sh-session
   $ cd dev
   $ ./phusion-ruby-fips.sh
   ```
## Testing

Tests are defined in `test.yaml` using [GoogleContainerTools/container-structure-test](https://github.com/GoogleContainerTools/container-structure-test).
To run tests, [build image](#Development) and execute 

   ```sh-session
docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $(pwd):/workspace \
  gcr.io/gcp-runtimes/container-structure-test:latest \
  test --image "image:tag" --config "/workspace/test.yml" --test-report "/workspace/test-results/report.json"
   ```
### Security testing 
To run vulnerability scanning using [trivy](https://github.com/aquasecurity/trivy) execute
   
   ```sh-session
 docker run --rm \
   -v /var/run/docker.sock:/var/run/docker.sock \
   -v ${pwd}:/workspace \
   aquasec/trivy:latest \
   --no-progress --ignorefile /workspace/.trivyignore --ignore-unfixed "image:tag"
   ```

## Releasing

Every night Jenkins job is triggered, and both images `ubuntu-ruby-fips:20.04-latest` and `phusion-ruby-fips:0.11-latest` updated and been delivered to Docker Hub.
