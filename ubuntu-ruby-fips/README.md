# Ubuntu container image
This container image includes Ubuntu version `22.04` which contains the following packages:

* OpenSSL: configured to be FIPS compliant.
* Ruby: compiled against the FIPS 140-2 compliant OpenSSL module.
* Postgres client: compiled against the FIPS 140-2 compliant OpenSSL module.
* Bundler.

The exact versions of packages mentioned above can be found in [Description.md](./Description.md).

## Build steps
#### Assumptions

1. Current directory is the directory where this repository is cloned
1. Docker version is 17.05 or higher


The Ubuntu container image will be built by a three-stage process:

1. The first stage builds the OpenSSL compiled with the FIPS 140-2 compliant OpenSSL module.
1. The second stage builds the Ruby and Postgres client packages.
1. The third stage ships the results of both stages, without the penalty of the build-chain and tooling.

### Docker images
| Image name  | Description |
|---|---|
| ubuntu-ruby-fips | Final image |


### Steps

Create the image:

$IMAGE_NAME is assumed to be the required name of Docker image

$IMAGE_TAG is assumed to be the required tag of Docker image
```
REPO_ROOT="$(git rev-parse --show-toplevel)"
docker build --build-arg "OPENSSL_BUILDER_TAG=$(< "${REPO_ROOT}"/openssl-builder/OPENSSL_BUILDER_TAG)" -t "$IMAGE_NAME":"$IMAGE_TAG" ubuntu-ruby-fips
```
