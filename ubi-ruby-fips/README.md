# UBI container image
This container image includes UBI version `9` which contains the following packages:

* OpenSSL: with FIPS 140-2 compliant OpenSSL module from RedHat UBI 9.
* Ruby: compiled against the FIPS 140-2 compliant OpenSSL module.
* Postgres client: compiled against the FIPS 140-2 compliant OpenSSL module.
* Bundler.

The exact versions of packages mentioned above can be found in [Description.md](./Description.md).
## Build steps
#### Assumptions

1. Current directory is the directory where this repository is cloned
1. Docker version is 17.05 or higher


### Docker images
| Image name  | Description |
|---|---|
| ubi-ruby | Final image |


### Steps

Create the image:
```
./ubi-ruby/build.sh
```
Create the final image:

$IMAGE_NAME is assumed to be the required name of Docker image

$IMAGE_TAG is assumed to be the required tag of Docker image
```
docker build -t "$IMAGE_NAME":"$IMAGE_TAG" ubi-ruby
```
