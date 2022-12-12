FROM ubuntu:18.04
ARG OPENSSL_VER

# We now get a precompiled version of OpenSSL that is already FIPS compliant.
# The DV team gets these files from the vendor (SafeLogic) and uploads 
# .tgz files for various OS platforms in artifactory. The file structure
# when the .tgz is inflated is very different from the file structure
# we got when we ran `make` directly on the openssl code. All the downstream
# usage assumes that old file structure though, so we need to rearrange 
# everything. The DV team is unlikely to rearrange the structure they package
# as a number of teams rely on the absence to the *.so files to force static
# linking and so when we have anything resembling our desired structure
# breaks multiple other teams. So, we get to move things around to where 
# we want them.

# Because we can't directly access Artifactory from our Jenkins executors
# right now, we manually download new releases from Artifactory and check 
# them into the conjurinc/openssl github repo. The build.sh script here
# checks out the repo
ADD openssl/openssl$OPENSSL_VER/openssl$OPENSSL_VER.tgz /usr/local/ssl

RUN \
    # Create the missing directories. Some of these stay empty, but they
    # exist in the compiled output
    mkdir /usr/local/ssl/certs && \
    mkdir /usr/local/ssl/fips-2.0 && \
    mkdir /usr/local/ssl/fips-2.0/bin && \
    mkdir /usr/local/ssl/private && \
    # Move around all the files
    mv /usr/local/ssl/bin/fips/fips_standalone_sha1 /usr/local/ssl/fips-2.0/bin && \
    mv /usr/local/ssl/bin/fips/fipsld /usr/local/ssl/fips-2.0/bin && \
    mv /usr/local/ssl/bin/fips/incore /usr/local/ssl/fips-2.0/bin && \
    mv /usr/local/ssl/bin/fips /usr/local/ssl/fips-2.0/lib && \
    mv /usr/local/ssl/include/fips/include /usr/local/ssl/fips-2.0/ && \
    mv /usr/local/ssl/Extension/bin/fips/incore /usr/local/ssl/fips-2.0/bin && \
    mv /usr/local/ssl/Extension/bin/fips/* /usr/local/ssl/bin && \
    mv /usr/local/ssl/Extension/lib/* /usr/local/ssl/lib && \
    mv /usr/local/ssl/Extension/misc /usr/local/ssl/ && \
    mv /usr/local/ssl/Extension/openssl.cnf /usr/local/ssl/ && \
    # Rename the libraries and make symbolic links to them. Otherwise, things won't compile
    mv /usr/local/ssl/lib/libcrypto.so /usr/local/ssl/lib/libcrypto.so.1.0.0 && \
    mv /usr/local/ssl/lib/libssl.so /usr/local/ssl/lib/libssl.so.1.0.0 && \
    ln -snf /usr/local/ssl/lib/libcrypto.so.1.0.0 /usr/local/ssl/lib/libcrypto.so && \
    ln -snf /usr/local/ssl/lib/libssl.so.1.0.0 /usr/local/ssl/lib/libssl.so && \
    # Clean up the unneeded directories that remain
    rm -rf /usr/local/ssl/Extension && \
    rm -rf /usr/local/ssl/include/fips

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
