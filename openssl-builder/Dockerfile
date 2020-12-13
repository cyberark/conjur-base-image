FROM ubuntu:18.04
ARG OPENSSL_FIPS_VER
ARG OPENSSL_FIPS_HMACSHA1=e8dbfa6cb9e22a049ec625ffb7ccaf33e6116598
ARG OPENSSL_FIPS_HASH=a3cd13d0521d22dd939063d3b4a0d4ce24494374b91408a05bdaca8b681c63d4
ARG OPENSSL_FIPS_PGP_FINGERPRINT=D3577507FA40E9E2
ARG OPENSSL_VER
ARG OPENSSL_HASH=ecd0c6ffb493dd06707d38b14bb4d8c2288bb7033735606569d8f90f89669d16
ARG OPENSSL_PGP_FINGERPRINT=8657ABB260F056B1E5190839D9C4D26D0E604491
RUN DEBIAN_FRONTEND=noninteractive apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential \
    equivs \
    perl \
    wget \
    gnupg2 \
    ca-certificates
COPY openssl_fips_pgp.key openssl_pgp.key /
RUN gpg --import openssl_fips_pgp.key \
    && gpg --import openssl_pgp.key \
    && wget --quiet https://www.openssl.org/source/openssl-fips-$OPENSSL_FIPS_VER.tar.gz \
    && openssl sha1 -hmac etaonrishdlcupfm openssl-fips-$OPENSSL_FIPS_VER.tar.gz | grep $OPENSSL_FIPS_HMACSHA1 \
    && wget --quiet https://www.openssl.org/source/openssl-fips-$OPENSSL_FIPS_VER.tar.gz.asc \
    && gpg --verify openssl-fips-$OPENSSL_FIPS_VER.tar.gz.asc openssl-fips-$OPENSSL_FIPS_VER.tar.gz \
    && echo "$OPENSSL_FIPS_HASH openssl-fips-$OPENSSL_FIPS_VER.tar.gz" | sha256sum -c - | grep OK \
    && wget --quiet https://www.openssl.org/source/openssl-$OPENSSL_VER.tar.gz \
    && wget --quiet https://www.openssl.org/source/openssl-$OPENSSL_VER.tar.gz.asc \
    && gpg --verify openssl-$OPENSSL_VER.tar.gz.asc \
    && echo "$OPENSSL_HASH openssl-$OPENSSL_VER.tar.gz" | sha256sum -c - | grep OK
RUN tar -xzf openssl-fips-$OPENSSL_FIPS_VER.tar.gz \
    && cd openssl-fips-$OPENSSL_FIPS_VER \
    && ./config -DPOINTER_TO_FUNCTION_IS_POINTER_TO_1ST_INSTRUCTION -DFIPS_REF_POINT_IS_CROSS_COMPILER_AWARE \
    && make \
    && make install \
    && cd .. \
    && tar -xzf openssl-$OPENSSL_VER.tar.gz \
    && cd openssl-$OPENSSL_VER \
    && ./config -Wl,-rpath=/usr/local/ssl/lib fips shared --openssldir=/usr/local/ssl --with-fipsdir=/usr/local/ssl/fips-2.0 --with-fipslibdir=/usr/local/ssl/fips-2.0/lib/ \
    && make depend \
    && make \
    && make install

COPY openssl libssl ca-certificates ./
RUN equivs-build openssl \
    && equivs-build libssl \
    && equivs-build ca-certificates
