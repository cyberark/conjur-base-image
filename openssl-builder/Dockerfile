FROM ubuntu:18.04
ARG OPENSSL_FIPS_VER
ARG OPENSSL_FIPS_HMACSHA1=e8dbfa6cb9e22a049ec625ffb7ccaf33e6116598
ARG OPENSSL_FIPS_HASH=a3cd13d0521d22dd939063d3b4a0d4ce24494374b91408a05bdaca8b681c63d4
ARG OPENSSL_FIPS_PGP_FINGERPRINT=D3577507FA40E9E2
ARG OPENSSL_VER
RUN DEBIAN_FRONTEND=noninteractive apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential \
    equivs \
    perl \
    wget \
    gnupg2 \
    ca-certificates
COPY openssl_fips_pgp.key /
RUN gpg --import openssl_fips_pgp.key \
    && wget --quiet https://www.openssl.org/source/openssl-fips-$OPENSSL_FIPS_VER.tar.gz \
    && openssl sha1 -hmac etaonrishdlcupfm openssl-fips-$OPENSSL_FIPS_VER.tar.gz | grep $OPENSSL_FIPS_HMACSHA1 \
    && wget --quiet https://www.openssl.org/source/openssl-fips-$OPENSSL_FIPS_VER.tar.gz.asc \
    && gpg --verify openssl-fips-$OPENSSL_FIPS_VER.tar.gz.asc openssl-fips-$OPENSSL_FIPS_VER.tar.gz \
    && echo "$OPENSSL_FIPS_HASH openssl-fips-$OPENSSL_FIPS_VER.tar.gz" | sha256sum -c - | grep OK
COPY openssl/openssl-$OPENSSL_VER /openssl
RUN tar -xzf openssl-fips-$OPENSSL_FIPS_VER.tar.gz \
    && cd openssl-fips-$OPENSSL_FIPS_VER \
    && ./config \
    && make \
    && make install \
    && cd ../openssl \
    && ./config -Wl,-rpath=/usr/local/ssl/lib fips shared --openssldir=/usr/local/ssl --with-fipsdir=/usr/local/ssl/fips-2.0 --with-fipslibdir=/usr/local/ssl/fips-2.0/lib/ \
    && make depend \
    && make \
    && make install

COPY openssl.control libssl.control ca-certificates.control /
RUN sed -i 's/\(Version: \).*/\1'"$OPENSSL_VER"'/' openssl.control
RUN sed -i 's/\(Version: \).*/\1'"$OPENSSL_VER"'/' libssl.control
RUN equivs-build openssl.control \
    && equivs-build libssl.control \
    && equivs-build ca-certificates.control
