# Table of Contents

- [Table of Contents](#table-of-contents)
- [Conjur Base Image](#Conjur-Base-Image)
- [Certification level](#Certification-level)
- [Feature](#Feature)
- [Usage](#Usage)
- [What is FIPS 140-2](#What-is-FIPS-140-2)
- [Contributing](#Contributing)
- [License](#license)

# Conjur Base Image

This repo builds a Docker image that contains OpenSSL, Ruby and PostgreSQL client libraries compiled against the FIPS 140-2 compliant OpenSSL module.

Two images included:
- [Phusion](./phusion-ruby-fips/) 
- [Ubuntu](./ubuntu-ruby-fips/) 

## Certification level

![](https://img.shields.io/badge/Certification%20Level-Trusted-007BFF?link=https://github.com/cyberark/community/blob/master/Conjur/conventions/certification-levels.md)

This repo is a **Trusted** level project. It has been reviewed by CyberArk to verify that it will securely
work with Conjur OSS as documented. For more detailed information on our certification levels, see
[our community guidelines](https://github.com/cyberark/community/blob/master/Conjur/conventions/certification-levels.md#community).


## Feature

* A minimal base image to reduce attack surface and external dependencies
* Vulnerability scanning
* Builder container for OpenSSL, Ruby, and PostgreSQL client
* Last security update
* Jenkins pipeline for building the Docker image
* Automated tests validate FIPS mode is successfully enabled and all artifacts are compiled against the FIPS 140-2 compliant
* One OpenSSL version installed in the image:
  * OpenSSL version: `openssl-1.0.2u`
  * OpenSSL FIPS Module version: `openssl-fips-2.0.16`
  
## Usage

- [Phusion](./phusion-ruby-fips/) image is the parent image of DAP Server
- [Ubuntu](./ubuntu-ruby-fips/) image is the parent image of Conur Server

## What is FIPS 140-2

The Federal Information Processing Standard Publication 140-2, (FIPS PUB 140-2), is a U.S. government computer security standard used to approve cryptographic modules.
The title is Security Requirements for Cryptographic Modules. 

For more information, visit the [FIPS 140-2 Wikipedia Page](https://en.wikipedia.org/wiki/FIPS_140-2).

## Contributing

We welcome contributions of all kinds to this repository. For instructions on how to get started and descriptions
of our development workflows, please see our [contributing guide](https://github.com/cyberark/conjur-base-image/blob/master/CONTRIBUTING.md).

## License

This repository is licensed under Apache License 2.0 - see [`LICENSE`](LICENSE) for more details.
