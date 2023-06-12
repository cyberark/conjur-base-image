#!/bin/bash

echo "# ubi-ruby-fips
\`ubi-ruby-fips\` combines a [base UBI image](https://catalog.redhat.com/software/containers/ubi9/618326f8c0d15aff4912fe0b)
with Ruby configured to be FIPS 140-2 compliant [OpenSSL module](https://www.openssl.org/docs/fips.html).
This image includes the following packages:

* OpenSSL version \`$OPENSSL_VERSION\`: with FIPS 140-2 compliant OpenSSL module from RedHat UBI 9.
* OpenSSL FIPS provider version \`$OPENSSL_VERSION\`: allowing the OpenSSL to work in FIPS-compliant mode.
* Ruby version \`$RUBY_FULL_VERSION\`: compiled against the FIPS 140-2 compliant OpenSSL module.
* Postgres client version \`$PG_VERSION\`: linked against the FIPS 140-2 compliant OpenSSL module.
* Bundler version \`$BUNDLER_VERSION\`.

Source code: https://github.com/cyberark/conjur-base-image" >./Description.md
