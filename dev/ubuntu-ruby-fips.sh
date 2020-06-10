#!/bin/bash

cd "$(dirname "$0")"

../openssl-builder/build.sh false
../openssl-builder/push.sh false

../ubuntu-ruby-builder/build.sh false
../ubuntu-ruby-builder/push.sh false

../postgres-client-builder/build.sh
../postgres-client-builder/tag.sh

../ubuntu-ruby-fips/build.sh dev
