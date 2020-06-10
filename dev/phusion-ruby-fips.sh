#!/bin/bash

cd "$(dirname "$0")"

../openssl-builder/build.sh false
../openssl-builder/push.sh false

../phusion-ruby-builder/build.sh false
../phusion-ruby-builder/push.sh false

../postgres-client-builder/build.sh
../postgres-client-builder/tag.sh

../phusion-ruby-fips/build.sh dev
