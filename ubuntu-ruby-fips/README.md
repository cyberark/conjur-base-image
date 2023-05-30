# Ubuntu container image
This container image includes Ubuntu version `22.04` which contains the following packages:

* OpenSSL: configured to be FIPS compliant.
* Ruby: compiled against the FIPS 140-2 compliant OpenSSL module.
* Postgres client: linked against the FIPS 140-2 compliant OpenSSL module.
* Bundler.

The exact versions of packages mentioned above can be found in [Description.md](./Description.md).

## Build step

### Important
The builder image **should not** be used as the eventual application image.
It should be solely used to **build** an actual application image.

FIPS module is disabled in `ubuntu-ruby-builder` image to take advantage of
dependency download optimization bundler utilizes.

Bundler uses MD5 Hash Algorithm which is not FIPS compliant, hence no optimization can be applied on images
with FIPS module enabled. This have a negative toll on the dependencies download speed.

#### Assumptions

1. Current directory is the directory where this repository is cloned
2. Docker version is `24` or higher


### Docker images
| Image name                     | Description                          |
|--------------------------------|--------------------------------------|
| ubuntu-ruby-builder            | Ruby image with building tools       |
| ubuntu-ruby-fips               | Final image                          |
| ubuntu-ruby-fips-postgres-fips | Final image with PostgreSQL database |
| ubuntu-ruby-fips-slim          | Lightweight final image              |


### Steps

To build the images execute:

```
./ubuntu-ruby-fips/build.sh
```
