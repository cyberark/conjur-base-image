#!/bin/bash

cd "$(dirname "$0")"

../openssl-builder/build.sh

../ubuntu-ruby-builder/build.sh

../postgres-client-builder/build.sh

../ubuntu-ruby-fips/build.sh dev
