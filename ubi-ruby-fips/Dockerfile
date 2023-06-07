ARG UBI_VERSION

# Ruby Builder
FROM registry.access.redhat.com/$UBI_VERSION/ubi as ubi-ruby-builder
ARG RUBY_MAJOR_VERSION
ARG RUBY_FULL_VERSION
ARG RUBY_SHA256

COPY build_ruby.sh .
RUN ./build_ruby.sh

# Conjur Base Image (UBI)
FROM registry.access.redhat.com/$UBI_VERSION/ubi as ubi-ruby-fips-slim
ARG BUNDLER_VERSION
ARG PG_VERSION

RUN yum -y update && \
  yum install -y libpq && \
  yum install -y https://download.postgresql.org/pub/repos/yum/${PG_VERSION%%.*}/redhat/rhel-9-$(uname -m)/postgresql${PG_VERSION%%.*}-libs-${PG_VERSION}-1PGDG.rhel9.$(uname -m).rpm && \
  yum install -y https://download.postgresql.org/pub/repos/yum/${PG_VERSION%%.*}/redhat/rhel-9-$(uname -m)/postgresql${PG_VERSION%%.*}-${PG_VERSION}-1PGDG.rhel9.$(uname -m).rpm && \
  yum --disableplugin=subscription-manager clean all && \
  echo "exclude=ruby*" >> /etc/yum.conf # disable ability to install ruby with package manager

## Copy ruby binaries from ubi-ruby-builder
RUN mkdir -p /var/lib/ruby/
COPY --from=ubi-ruby-builder /var/lib/ruby/ /var/lib/ruby/
ENV PATH="/var/lib/ruby/bin:${PATH}"

## Install Ruby tools
RUN gem install --no-document bundler:$BUNDLER_VERSION

CMD irb

# Conjur Base Image (UBI)
FROM ubi-ruby-fips-slim as ubi-ruby-fips-dev

RUN mkdir docs
COPY generate-description.sh ./docs/generate-description.sh

RUN yum -y update && \
  yum install -y jq && \
  yum --disableplugin=subscription-manager clean all
#  rm -rf /var/cache/yum
