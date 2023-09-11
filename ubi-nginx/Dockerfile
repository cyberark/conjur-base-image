ARG UBI_VERSION

FROM registry.access.redhat.com/$UBI_VERSION/ubi

ARG WWWDATA_UID=888

# Ports below 1024 are privileged in OpenShift, so we configure these to serve
# http / https traffic in conjur.conf.
EXPOSE 9000 9443

ENV HOME=/var/www \
    SSL_CERT_DIRECTORY=/opt/conjur/etc/ssl

LABEL name="ubi-nginx" \
      vendor="CyberArk" \
      version="$UBI_VERSION" \
      release="$UBI_VERSION" \
      summary="UBI-based Nginx image for use with Conjur" \
      description="UBI-based Nginx image for use with Conjur"

COPY yum/nginx.repo /etc/yum.repos.d/

RUN dnf config-manager --add-repo /etc/yum.repos.d/nginx.repo && \
    dnf -y update && \
    dnf install -y --nodocs \
      bind-utils \
      gettext \
      hostname \
      nginx \
      nss_wrapper && \
    dnf clean all && \
    rm -rf /var/cache/yum /var/cache/dnf /var/lib/dnf && \
    # Remove default site config
    rm -rf /etc/nginx/conf.d/*

# Create nginx user with one that has known gid / uid.
RUN groupadd -g ${WWWDATA_UID} \
             -r www-data && \
    useradd -g www-data \
            -d "$HOME" \
            -r \
            -m \
            -s /bin/bash \
            -u ${WWWDATA_UID} www-data

COPY bin/ /usr/bin/

RUN test "$(id www-data)" = "uid=${WWWDATA_UID}(www-data) gid=${WWWDATA_UID}(www-data) groups=${WWWDATA_UID}(www-data)" && \
    # Remove /var/run symlink that Docker creates.
    rm /var/run && \
    # Wipe out default content (such as default nginx website).
    rm -rf $HOME \
           /etc/nginx && \
    # Create these now because user in container will not have permission.
    mkdir -p "$HOME" \
             "/etc/nginx/sites-enabled" \
             "/var/log/nginx" \
             "/var/tmp/nginx" \
             "/var/run/nginx" \
             "$SSL_CERT_DIRECTORY/ca" \
             "$SSL_CERT_DIRECTORY/cert" && \
    # Create symlinks to direct nginx logs to stdout and stderr
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log && \
    # Ensure user in container will be able to read / write these.
    fix-permissions -u www-data "$HOME" \
                                "/etc/nginx" \
                                "/etc/ssl" \
                                "/var/log/nginx" \
                                "/var/tmp/nginx" \
                                "/var/run/nginx" \
                                "$SSL_CERT_DIRECTORY"

COPY ./config/nginx.conf \
     ./config/mime.types \
     ./config/dhparams.pem /etc/nginx/
COPY ./config/conjur.conf /etc/nginx/sites-enabled

COPY LICENSE /licenses/

USER ${WWWDATA_UID}

ENTRYPOINT ["exec-entrypoint"]
CMD ["run-nginx"]
