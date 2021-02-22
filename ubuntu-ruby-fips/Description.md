# ubuntu-ruby-fips
 `ubuntu-ruby-fips` combines a [base Ubuntu image](https://hub.docker.com/_/ubuntu) 
 with Ruby compiled against the FIPS 140-2 compliant [OpenSSL module](https://www.openssl.org/docs/fips.html).  
This image includes the following packages:

* OpenSSL version `1.0.2u`: built with  FIPS 140-2 compliant OpenSSL module version `2.0.16`.
* Ruby version `2.5`: compiled against the FIPS 140-2 compliant OpenSSL module.
* Postgres client version `10-10.15`: compiled against the FIPS 140-2 compliant OpenSSL module.
* Bundler version `2.2.11`.
 
Source code: https://github.com/cyberark/conjur-base-image
