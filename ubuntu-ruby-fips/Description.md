# ubuntu-ruby-fips
 `ubuntu-ruby-fips` combines a [base Ubuntu image](https://hub.docker.com/_/ubuntu)
 with Ruby compiled against the FIPS 140-2 compliant [OpenSSL module](https://www.openssl.org/docs/fips.html).
This image includes the following packages:

* OpenSSL version `3.0.2`: built by SafeLogic to be FIPS-compliant.
* Ruby version `3.2.2`: compiled against the FIPS 140-2 compliant OpenSSL module.
* Postgres client version `15.3`: compiled against the FIPS 140-2 compliant OpenSSL module.
* Bundler version `2.4.13`.

Source code: https://github.com/cyberark/conjur-base-image
