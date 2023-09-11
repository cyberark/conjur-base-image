#!/bin/bash

echo "# ubuntu-ruby-fips
 \`ubuntu-ruby-fips\` combines a [base Ubuntu image](https://hub.docker.com/_/ubuntu)
with Ruby configured to be FIPS 140-2 compliant [OpenSSL module](https://www.openssl.org/docs/fips.html).
This image includes the following packages:

* OpenSSL version \`$OPENSSL_VERSION\`: configured to be FIPS-compliant.
* OpenSSL FIPS provider version \`$OPEN_SSL_FIPS_PROVIDER_VERSION\`: allowing the OpenSSL to work in FIPS-compliant mode.
* Ruby version \`$RUBY_FULL_VERSION\`: compiled against the FIPS 140-2 compliant OpenSSL module.
* Postgres client version \`$PG_VERSION\`: linked against the FIPS 140-2 compliant OpenSSL module.
* Bundler version \`$BUNDLER_VERSION\`.

Source code: https://github.com/cyberark/conjur-base-image" >./Description.md
