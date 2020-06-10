#!/bin/bash

cd "$(dirname "$0")"

PG_VERSION=12-12.2
docker tag postgres-client-builder:"$PG_VERSION-fips" registry.tld/postgres-client-builder:"$PG_VERSION-fips"
