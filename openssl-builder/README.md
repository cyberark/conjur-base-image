# ubuntu-openssl-builder
An openssl FIPS 140-2 builder

* OpenSSL: `openssl-1.0.2u`
* OpenSSL FIPS Module: `openssl-fips-2.0.16`

## Build steps
The Dockerfile builds the FIPS canister per the requirements in "OpenSSL FIPS 140-2 Security Policy Version 2.0.16." It also verifies the SHA256 hash and PGP signature of the OpenSSL source based on OpenSSL's best practices recommendations.

## Running FIPS Enabled Container
OpenSSL FIPS mode is OFF by default. It can be turned on by either setting
the environment variable:
```
docker run -it -e "OPENSSL_FIPS=1" --name fips-base-image /bin/bash
```
