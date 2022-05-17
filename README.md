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

This repo builds a Docker image that contains OpenSSL, Ruby and PostgreSQL client libraries compiled against the FIPS 140-2 compliant OpenSSL module.

Three images included:
- [Phusion](./phusion-ruby-fips/)
- [Ubuntu](./ubuntu-ruby-fips/)
- [UBI](./ubi-ruby-fips/)

## Certification level

![](https://img.shields.io/badge/Certification%20Level-Trusted-007BFF?link=https://github.com/cyberark/community/blob/main/Conjur/conventions/certification-levels.md)

This repo is a **Trusted** level project. It has been reviewed by CyberArk to verify that it will securely
work with Conjur Open Source as documented. For more detailed information on our certification levels, see
[our community guidelines](https://github.com/cyberark/community/blob/main/Conjur/conventions/certification-levels.md#community).


## Feature

* A minimal base image to reduce attack surface and external dependencies
* Vulnerability scanning
* Builder container for OpenSSL, Ruby, and PostgreSQL client
* Last security update
* Jenkins pipeline for building the Docker image
* Automated tests validate FIPS mode is successfully enabled and all artifacts are compiled against the FIPS 140-2 compliant
* OpenSSL version installed in the Phusion and Ubuntu images:
  * OpenSSL version: `openssl-1.0.2ze`
  * OpenSSL FIPS Module version: `openssl-fips-2.0.16`
* OpenSSL version installed in the UBI image:
  * OpenSSL version: `openssl-1.1.1-1ubuntu2.1-18.04.17`

## Usage

- [Phusion](./phusion-ruby-fips/) image is the parent image of Conjur Enterprise Server
- [Ubuntu](./ubuntu-ruby-fips/) image is the parent image of Conjur Server
- [UBI](./ubi-ruby-fips/) image is the parent image of Conjur Server for OpenShift

## What is FIPS 140-2

The Federal Information Processing Standard Publication 140-2, (FIPS PUB 140-2), is a U.S. government computer security standard used to approve cryptographic modules.
The title is Security Requirements for Cryptographic Modules.

For more information, visit the [FIPS 140-2 Wikipedia Page](https://en.wikipedia.org/wiki/FIPS_140-2).

## Contributing

We welcome contributions of all kinds to this repository. For instructions on how to get started and descriptions
of our development workflows, please see our [contributing guide](https://github.com/cyberark/conjur-base-image/blob/main/CONTRIBUTING.md).

## License

This repository is licensed under Apache License 2.0 - see [`LICENSE`](LICENSE) for more details.
