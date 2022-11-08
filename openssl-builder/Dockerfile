FROM ubuntu:18.04
ARG OPENSSL_VER

ADD openssl/openssl$OPENSSL_VER/openssl$OPENSSL_VER.tgz /usr/local/ssl

# The next 3 RUN statements are because the structure in the tgz file 
# doesn't match the structure created by the OpenSSL build. The DV team
# sets the structure for the executable, but can't change it right now due
# to deadlines and resource constraints. Eventually, we should work with 
# them to get everything in the right place, but for now, we just move 
# everything around ourselves.

# The tgz file puts the binaries in a fips subdirectory in bin. Move them 
# back to where they're expected (up one level, just in /usr/local/ssl/bin)
RUN mv /usr/local/ssl/bin/fips/c_rehash /usr/local/ssl/bin && \
    mv /usr/local/ssl/bin/fips/openssl /usr/local/ssl/bin

# Make symbolic links. Not sure exactly why it's needed, but base images 
# later in the build fail if files aren't set like this. 
RUN mv /usr/local/ssl/lib/libcrypto.so /usr/local/ssl/lib/libcrypto.so.1.0.0 && \
    ln -snf /usr/local/ssl/lib/libcrypto.so.1.0.0 /usr/local/ssl/lib/libcrypto.so && \
    mv /usr/local/ssl/lib/libssl.so /usr/local/ssl/lib/libssl.so.1.0.0 && \
    ln -snf /usr/local/ssl/lib/libssl.so.1.0.0 /usr/local/ssl/lib/libssl.so

# Make the /usr/local/ssl directory look like when we compiled everything
RUN mkdir /usr/local/ssl/certs && \
    mkdir /usr/local/ssl/fips-2.0 && \
    mkdir /usr/local/ssl/fips-2.0/bin && \
    mv /usr/local/ssl/bin/fips/fips_standalone_sha1 /usr/local/ssl/fips-2.0/bin && \
    mv /usr/local/ssl/bin/fips/fipsld /usr/local/ssl/fips-2.0/bin && \
    mv /usr/local/ssl/bin/fips/incore /usr/local/ssl/fips-2.0/bin && \
    mv /usr/local/ssl/include/fips/include /usr/local/ssl/fips-2.0/include && \
    rm -rf /usr/local/ssl/include/fips && \
    mv /usr/local/ssl/bin/fips /usr/local/ssl/fips-2.0/lib && \
    mkdir /usr/local/ssl/private

# Make the fake Debian packages that are used for later base images
RUN DEBIAN_FRONTEND=noninteractive apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    equivs \
    ca-certificates

COPY openssl.control libssl.control ca-certificates.control /
RUN sed -i 's/\(Version: \).*/\1'"$OPENSSL_VER"'/' openssl.control
RUN sed -i 's/\(Version: \).*/\1'"$OPENSSL_VER"'/' libssl.control
RUN equivs-build openssl.control \
    && equivs-build libssl.control \
    && equivs-build ca-certificates.control
