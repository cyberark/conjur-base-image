#!/bin/bash

set -e

action=

if ! command -v openssl &>/dev/null; then
	echo "openssl could not be found"
	exit 1
fi

OPENSSL_MODULES=$(openssl version -m | sed -n 's/.*"\(.*\)"/\1/p')
OPENSSL_DIR=$(openssl version -d | sed -n 's/.*"\(.*\)"/\1/p')

while getopts a: name; do
	case $name in
	a) action="$OPTARG" ;;
	?) printf "Usage: %s: [-a action] \n\t where action can be enable or disable\n" "$0" && exit 2 ;;
	esac
done

function fips_enabled() {
	openssl list -providers | grep -qwF fips
}

function print_fips_state() {
	if fips_enabled; then
		echo "FIPS mode is enabled"
	else
		echo "FIPS mode is disabled"
	fi
}

function first_time_install() {
	if [ -f "${OPENSSL_MODULES}/fips.so" ]; then
		return
	fi

	mv /usr/local/lib/fips.so "${OPENSSL_MODULES}"
	openssl fipsinstall -module "${OPENSSL_MODULES}/fips.so" -out "${OPENSSL_DIR}"/fipsmodule.cnf -provider_name fips
}

function toggle_fips() {
	OPTS=
	if [ "$1" = false ]; then
		OPTS="-R"
	fi
	OPENSSL_CONF=$(realpath "${OPENSSL_DIR}"/openssl.cnf)
	patch ${OPTS} "${OPENSSL_CONF}" <<EOF
51c51
< # .include fipsmodule.cnf
---
> .include /usr/lib/ssl/fipsmodule.cnf
53a54
> alg_section = algorithm_sect
62c63
< # fips = fips_sect
---
> fips = fips_sect
73c74
< # activate = 1
---
> activate = 1
397a399,402
> MinProtocol = TLSv1.3
> MinProtocol = DTLSv1.3
> [algorithm_sect]
> default_properties = "fips=yes"
EOF
}

case $action in
enable)
	if fips_enabled; then
		echo "FIPS mode already enabled"
		exit 2
	fi
	first_time_install
	toggle_fips true
	print_fips_state
	;;
disable)
	if ! fips_enabled; then
		echo "FIPS mode already disabled"
		exit 2
	fi
	toggle_fips false
	print_fips_state
	;;
"") print_fips_state ;;
*) echo "invalid action" ;;
esac
#
#
#cp /etc/ssl/openssl.cnf /etc/ssl/openssl.cnf.old
##
#sed -i 's/\[openssl_init\]/\[openssl_init\]\nalg_section = algorithm_sect/g' /etc/ssl/openssl.cnf
#sed -i 's/# .include fipsmodule.cnf/.include \/etc\/ssl\/fipsmodule.cnf/g' /etc/ssl/openssl.cnf
#sed -i '/fips = fips_sect/s/^# *//' /etc/ssl/openssl.cnf
#printf "[algorithm_sect]\ndefault_properties = fips=yes" >>/etc/ssl/openssl.cnf

set +e
