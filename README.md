# Table of Contents

- [Table of Contents](#table-of-contents)
- [Conjur Base Image](#conjur-base-image)
  - [Certification level](#certification-level)
  - [Feature](#feature)
  - [Usage](#usage)
  - [What is FIPS 140-2](#what-is-fips-140-2)
  - [Contributing](#contributing)
  - [License](#license)

# Conjur Base Image

This repo builds a Docker image that contains Ruby client libraries compiled against the FIPS 140-2 compliant OpenSSL module.

Two images included:
- [Ubuntu](./ubuntu-ruby-fips/)
- [UBI](./ubi-ruby-fips/)

## Feature

* A minimal base image to reduce attack surface and external dependencies
* Vulnerability scanning
* Builder container for Ruby client
* Last security update
* Jenkins pipeline for building the Docker image
* Automated tests validate FIPS mode is successfully enabled and all artifacts are compiled against the FIPS 140-2 compliant
* OpenSSL version installed in the Ubuntu image:
  * OpenSSL version: `3` (configured to be FIPS-Compliant)
* OpenSSL version installed in the UBI image:
  * OpenSSL version: `3` (with FIPS 140-2 compliant OpenSSL module from RedHat UBI 9)

## Usage

- [Ubuntu](./ubuntu-ruby-fips/) image is the parent image of Conjur Server
- [UBI](./ubi-ruby-fips/) image is the parent image of Conjur Server for OpenShift

## What is FIPS 140-2

The Federal Information Processing Standard Publication 140-2, (FIPS PUB 140-2), is a U.S. government computer security standard used to approve cryptographic modules.
The title is Security Requirements for Cryptographic Modules.

For more information, visit the [FIPS 140-2 Wikipedia Page](https://en.wikipedia.org/wiki/FIPS_140-2).

### Important

For [UBI](./ubi-ruby-fips/) image FIPS module is disabled by default.
Please refer to [this readme](./ubi-ruby-fips/README.md) for more information.

## Contributing

We welcome contributions of all kinds to this repository. For instructions on how to get started and descriptions
of our development workflows, please see our [contributing guide](https://github.com/cyberark/conjur-base-image/blob/main/CONTRIBUTING.md).

## License

This repository is licensed under Apache License 2.0 - see [`LICENSE`](LICENSE) for more details.
