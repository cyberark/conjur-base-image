# Phusion container image
This container image includes Phusion version `0.11` which contains the following packages:

* OpenSSL version `1.0.2u`: built with  FIPS 140-2 compliant OpenSSL module version: `2.0.16`.
* Ruby version `2.5`: compiled against the FIPS 140-2 compliant OpenSSL module.
* Postgres client version `10-10.15`: compiled against the FIPS 140-2 compliant OpenSSL module.
* OpenLDAP version `2.4.46`: built using openssl rather than gnutls and compiled against the FIPS 140-2 compliant OpenSSL module.
* Bundler version `2.2.11`.
 

## Build steps
#### Assumptions

1. Current directory is the directory where this repository is cloned
1. Docker version is 17.05 or higher


The Phusion container image will be built by a three-stage process: 

1. The first stage builds the OpenSSL compiled with the FIPS 140-2 compliant OpenSSL module.
1. The second stage builds the Ruby, Postgres client, and OpenLDAP packages.
1. The third stage ships the results of both stages, without the penalty of the build-chain and tooling.

### Docker images    
| Image name  | Description |
|---|---|
| openssl-builder | Installs OpenSSL with the FIPS 140-2 compliant module|
| postgres-client-builder | Installs Postgres client |
| phusion-ruby-builder | Installs Ruby version |
| phusion-openldap-builder | Installs OpenLDAP using OpenSSL |
| phusion-ruby-fips | Final image |


### Steps

Create image for openssl-builder: 
```
./openssl-builder/build.sh
```
Create images for phusion-ruby-builder and postgres-client-builder:
```
./postgres-client-builder/build.sh
./phusion-ruby-builder/build.sh
./phusion-openldap-builder/build.sh
```
Create the final image:

$IMAGE_NAME is assumed to be the required name of Docker image

$IMAGE_TAG is assumed to be the required tag of Docker image
```
docker build --build-arg "OPENSSL_BUILDER_TAG=1.0.2u-fips-2.0.16" -t "$IMAGE_NAME":"$IMAGE_TAG" phusion-ruby-fips
```
