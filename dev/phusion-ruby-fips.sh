#!/bin/bash

cd "$(dirname "$0")"

../openssl-builder/build.sh

../phusion-ruby-builder/build.sh

../postgres-client-builder/build.sh

../phusion-ruby-fips/build.sh dev
