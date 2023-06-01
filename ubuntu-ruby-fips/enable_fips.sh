#!/bin/bash

set -e

OPENSSL_MODULES=$(openssl version -m | sed -n 's/.*"\(.*\)"/\1/p')

mv /usr/local/lib/fips.so "${OPENSSL_MODULES}"

openssl fipsinstall -module "${OPENSSL_MODULES}/fips.so" -out /etc/ssl/fipsmodule.cnf -provider_name fips

sed -i 's/\[openssl_init\]/\[openssl_init\]\nalg_section = algorithm_sect/g' /etc/ssl/openssl.cnf
sed -i 's/# .include fipsmodule.cnf/.include \/etc\/ssl\/fipsmodule.cnf/g' /etc/ssl/openssl.cnf
sed -i '/fips = fips_sect/s/^# *//' /etc/ssl/openssl.cnf
printf "\n[algorithm_sect]\ndefault_properties = fips=yes" >>/etc/ssl/openssl.cnf

set +e
