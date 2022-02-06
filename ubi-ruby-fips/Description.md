# ubi-ruby-fips
 `ubi-ruby-fips` combines a [base UBI image](https://catalog.redhat.com/software/containers/ubi8/ubi/5c359854d70cc534b3a3784e) 
 with Ruby compiled against the FIPS 140-2 compliant [OpenSSL module](https://www.openssl.org/docs/fips.html).  
This image includes the following packages:

* OpenSSL version `1.1.1c`: with FIPS 140-2 compliant OpenSSL module from RedHat UBI 8.
* Ruby version `3.0.2`: compiled against the FIPS 140-2 compliant OpenSSL module.
* Postgres client version `10-10.16`: compiled against the FIPS 140-2 compliant OpenSSL module.
* Bundler version `2.2.30`.
 
Source code: https://github.com/cyberark/conjur-base-image
