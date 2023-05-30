# ubuntu-ruby-fips
 `ubuntu-ruby-fips` combines a [base Ubuntu image](https://hub.docker.com/_/ubuntu)
with Ruby configured to be FIPS 140-2 compliant [OpenSSL module](https://www.openssl.org/docs/fips.html).
This image includes the following packages:

* OpenSSL version `3.0.2`: configured to be FIPS-compliant.
* OpenSSL FIPS provider version `3.0.9`: allowing the OpenSSL to work in FIPS-compliant mode.
* Ruby version `3.2.2`: compiled against the FIPS 140-2 compliant OpenSSL module.
* Postgres client version `15.4`: linked against the FIPS 140-2 compliant OpenSSL module.
* Bundler version `2.4.14`.

Source code: https://github.com/cyberark/conjur-base-image
