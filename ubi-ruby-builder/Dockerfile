# Declare UBI and Ruby versions
ARG UBI_VERSION
ARG RUBY_MAJOR_VERSION
ARG RUBY_FULL_VERSION

# Ruby Builder
FROM registry.access.redhat.com/$UBI_VERSION/ubi
ARG RUBY_MAJOR_VERSION
ARG RUBY_FULL_VERSION
ARG RUBY_SHA256=9afc6380a027a4fe1ae1a3e2eccb6b497b9c5ac0631c12ca56f9b7beb4848776

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
