# ubuntu-ruby-fips
 `ubuntu-ruby-fips` combines a [base Ubuntu image](https://hub.docker.com/_/ubuntu)
with Ruby configured to be FIPS 140-2 compliant [OpenSSL module](https://www.openssl.org/docs/fips.html).
This image includes the following packages:

* OpenSSL version `3.0.13`: configured to be FIPS-compliant.
* OpenSSL FIPS provider version `3.1.2`: allowing the OpenSSL to work in FIPS-compliant mode.
* Ruby version `4.0.5`: compiled against the FIPS 140-2 compliant OpenSSL module.
* Postgres client version `18.4`: linked against the FIPS 140-2 compliant OpenSSL module.
* Bundler version `4.0.12`.

Source code: https://github.com/cyberark/conjur-base-image
