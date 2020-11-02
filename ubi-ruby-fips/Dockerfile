ARG UBI_VERSION
ARG RUBY_BUILDER_TAG
ARG BUNDLER_VERSION=2.1.4

# Ruby Builder
FROM ubi-ruby-builder:$RUBY_BUILDER_TAG as ubi-ruby-builder

# Conjur Base Image (UBI)
FROM registry.access.redhat.com/$UBI_VERSION/ubi
ARG BUNDLER_VERSION

### We need libreadline-dev for its readline capabilities
RUN yum install -y --setopt=tsflags=nodocs http://mirror.centos.org/centos/8/BaseOS/x86_64/os/Packages/readline-devel-7.0-10.el8.x86_64.rpm && \
### Install openssl, postgresql client
    yum install -y openssl && \
    yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm && \
    yum install -y postgresql10

## Copy ruby binaries from ubi-ruby-builder
RUN mkdir -p /var/lib/ruby/
COPY --from=ubi-ruby-builder /var/lib/ruby/ /var/lib/ruby/
ENV PATH="/var/lib/ruby/bin:${PATH}"

## Install Ruby tools
RUN gem install --no-document bundler:$BUNDLER_VERSION