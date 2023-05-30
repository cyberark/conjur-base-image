# ubi-ruby-fips
`ubi-ruby-fips` combines a [base UBI image](https://catalog.redhat.com/software/containers/ubi9/618326f8c0d15aff4912fe0b)
with Ruby configured to be FIPS 140-2 compliant [OpenSSL module](https://www.openssl.org/docs/fips.html).
This image includes the following packages:

* OpenSSL version `3.0.7`: with FIPS 140-2 compliant OpenSSL module from RedHat UBI 9.
  Please note FIPS module is disabled by default for this image. For more information
  and toggling on/off procedure refer to [readme](./ubi-ruby-fips/README.md).
* OpenSSL FIPS provider version `3.0.7`: allowing the OpenSSL to work in FIPS-compliant mode.
* Ruby version `3.2.2`: compiled against the FIPS 140-2 compliant OpenSSL module.
* Postgres client version `15.4`: linked against the FIPS 140-2 compliant OpenSSL module.
* Bundler version `2.4.14`.

Source code: https://github.com/cyberark/conjur-base-image
