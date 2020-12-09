# UBI container image
This container image includes UBI version `8` which contains the following packages:

* OpenSSL version `1.1.1c`: with FIPS 140-2 compliant OpenSSL module from RedHat UBI 8.
* Ruby version `2.5`: compiled against the FIPS 140-2 compliant OpenSSL module.
* Postgres client version `10-10.15`: compiled against the FIPS 140-2 compliant OpenSSL module.
* Bundler version `2.1.4`.
 

## Build steps
#### Assumptions

1. Current directory is the directory where this repository is cloned
1. Docker version is 17.05 or higher


### Docker images    
| Image name  | Description |
|---|---|
| ubi-ruby-builder | Installs Ruby version |
| ubi-ruby | Final image |


### Steps

Create image for ubi-ruby-builder:
```
./ubi-ruby-builder/build.sh
```
Create the final image:

$IMAGE_NAME is assumed to be the required name of Docker image

$IMAGE_TAG is assumed to be the required tag of Docker image
```
docker build -t "$IMAGE_NAME":"$IMAGE_TAG" ubi-ruby
```