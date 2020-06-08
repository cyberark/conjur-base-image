#!/bin/bash
image_tag=$1
docker tag conjur-fips-ubuntu:"$image_tag" registry2.itci.conjur.net/conjur-fips-ubuntu:1.0.0
