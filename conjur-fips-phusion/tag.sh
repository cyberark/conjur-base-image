#!/bin/bash
image_tag=$1
docker tag conjur-fips-phusion:"$image_tag" registry2.itci.conjur.net/conjur-fips-phusion:1.0.0
