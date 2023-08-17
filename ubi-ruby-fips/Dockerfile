ARG UBI_VERSION

# ==============================================================================
# Ruby FIPS Builder
# ==============================================================================
FROM registry.access.redhat.com/$UBI_VERSION/ubi as ubi-ruby-fips-builder
ARG RUBY_FULL_VERSION
ARG RUBY_MAJOR_VERSION
ARG RUBY_SHA256

RUN yum -y clean all && yum -y makecache && yum -y update

RUN yum install -y --setopt=tsflags=nodocs gcc \
                                           gcc-c++ \
                                           make \
                                           openssl-devel \
                                           wget \
                                           zlib-devel
RUN yum install -y --setopt=tsflags=nodocs http://mirror.centos.org/centos/8-stream/BaseOS/x86_64/os/Packages/readline-devel-7.0-10.el8.x86_64.rpm

## Compile ruby
RUN wget --quiet https://cache.ruby-lang.org/pub/ruby/$RUBY_MAJOR_VERSION/ruby-$RUBY_FULL_VERSION.tar.gz && \
    echo "$RUBY_SHA256 ruby-$RUBY_FULL_VERSION.tar.gz" | sha256sum -c - && \
    tar -xvf ruby-$RUBY_FULL_VERSION.tar.gz && \
    cd ruby-$RUBY_FULL_VERSION && \
    ./configure --prefix=/var/lib/ruby && \
    make -j4 && \
    make install

# ==============================================================================
# Conjur Base Image (UBI)
# ==============================================================================
FROM registry.access.redhat.com/$UBI_VERSION/ubi as ubi-ruby-fips-slim
ARG BUNDLER_VERSION

RUN yum -y update && \
### We need libreadline-dev for its readline capabilities
    yum install -y --setopt=tsflags=nodocs http://mirror.centos.org/centos/8-stream/BaseOS/x86_64/os/Packages/readline-devel-7.0-10.el8.x86_64.rpm && \
### Perl(IPC::Run) is required for postgres15-devel so install it and its dependencies
    yum install -y http://mirror.centos.org/centos/8-stream/PowerTools/x86_64/os/Packages/perl-IO-Tty-1.12-11.el8.x86_64.rpm \
                   http://mirror.centos.org/centos/8-stream/PowerTools/x86_64/os/Packages/perl-Readonly-2.05-5.el8.noarch.rpm \
                   http://mirror.centos.org/centos/8-stream/PowerTools/x86_64/os/Packages/perl-IPC-Run-0.99-1.el8.noarch.rpm && \
### Remove the private keys included in Perl-IO and perl-Net-SSLeay
    rm -rf /usr/share/doc/perl-IO-Socket-SSL/certs/* && \
    rm -rf /usr/share/doc/perl-Net-SSLeay/examples/server_key.pem && \
### Install openssl, postgresql client
    yum install -y openssl && \
    yum install -y https://download.postgresql.org/pub/repos/yum/15/redhat/rhel-8-x86_64/postgresql15-libs-15.3-1PGDG.rhel8.x86_64.rpm \
                   https://download.postgresql.org/pub/repos/yum/15/redhat/rhel-8-x86_64/postgresql15-15.3-1PGDG.rhel8.x86_64.rpm \
                   https://download.postgresql.org/pub/repos/yum/15/redhat/rhel-8-x86_64/postgresql15-devel-15.3-1PGDG.rhel8.x86_64.rpm

## Copy ruby binaries from ubi-ruby-builder
RUN mkdir -p /var/lib/ruby/
COPY --from=ubi-ruby-fips-builder /var/lib/ruby/ /var/lib/ruby/
ENV PATH="/usr/pgsql-15/bin:/var/lib/ruby/bin:${PATH}"

## Install Ruby tools
RUN gem install --no-document bundler:$BUNDLER_VERSION

# ==============================================================================
# Ruby Builder
# ==============================================================================
FROM ubi-ruby-fips-slim as ubi-ruby-builder

RUN yum -y update && \
    yum install -y gcc \
                   gcc-c++ \
                   git \
                   glibc-devel \
                   libxml2-devel \
                   libxslt-devel \
                   make

# ==============================================================================
# Conjur Base Image (UBI) with dev tooling
# ==============================================================================
FROM ubi-ruby-fips-slim as ubi-ruby-fips-dev
