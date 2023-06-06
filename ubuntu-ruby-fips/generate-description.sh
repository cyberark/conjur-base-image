#!/bin/bash

OPENSSL_VERSION=$(openssl version | sed 's/^.*[^0-9]\([0-9]*\.[0-9]*\.[0-9]*\).*$/\1/')

echo "# ubuntu-ruby-fips
 \`ubuntu-ruby-fips\` combines a [base Ubuntu image](https://hub.docker.com/_/ubuntu)
 with Ruby compiled against the FIPS 140-2 compliant [OpenSSL module](https://www.openssl.org/docs/fips.html).
This image includes the following packages:

* OpenSSL version \`$OPENSSL_VERSION\`: built by SafeLogic to be FIPS-compliant.
* Ruby version \`$RUBY_FULL_VERSION\`: compiled against the FIPS 140-2 compliant OpenSSL module.
* Postgres client version \`$PG_VERSION\`: compiled against the FIPS 140-2 compliant OpenSSL module.
* Bundler version \`$BUNDLER_VERSION\`.

Source code: https://github.com/cyberark/conjur-base-image" > ./Description.md
