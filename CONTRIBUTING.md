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
   $ ./ubuntu-ruby-fips
   ```
To build Phusion base image:
   ```sh-session
   $ cd dev
   $ ./phusion-ruby-fips
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

Alternatively, you can run the `./{image-name}/test` script after building
the image and view the results in the `./test-results/` folder.

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

When the images have been updated and new versions should be released, you can
follow the standard [release process](https://github.com/cyberark/community/blob/main/Conjur/CONTRIBUTING.md#release-process)
to publish new versions of the image to public registries:

1. Create a new branch for the version bump.
   - Increment the [VERSION](./VERSION) following semantic versioning.
   - Review the git history and ensure the [changelog](./CHANGELOG.md) includes
     all recent relevant changes with references to GitHub issues / PRs.
   - Review the changes since the last release, and if the dependencies have
     changed revise the [NOTICES.txt](./NOTICES.txt) to correctly capture the
     included dependencies and their licenses / copyrights.
   - Commit these changes- `Bump version to x.y.z` is an acceptable commit
     message - and open a PR for review.
1. Merge the version bump PR, and tag the repo with the new version.
   - Ensure you are working from a current clone of the main branch
   - Tag the version using `git tag -s "v$(cat VERSION)" -m "v$(cat VERSION)"`.
   - Push the tag: `git push origin "v1.x.y"`.
1. Create a release from the new tag from the GitHub UI.
   - Copy the changelog from the new version into the GitHub release description.
   - The pipeline will automatically publish images to public image registries
     in the tag-triggered build.
   - Visit the [Nginx Red Hat project page](https://connect.redhat.com/project/5899451/view)
     once the images have been pushed and manually choose to publish the latest
     release.
1. Update the Dockerfiles in the Conjur project to point to the new base image
   versions. Images that needs updates include:
   - gems/policy-parser/Dockerfile.test
   - dev/Dockerfile.dev
   - Dockerfile
   - Dockerfile.ubi
1. Update the Conjur Enterprise Dockerfile to point to the new base image version.
