FROM httpd:2.4

MAINTAINER Simon Marti <simon.marti@schulebruegg.ch>

EXPOSE 80 443

# Build variables
ENV TEMPLATE_PATH=/etc/templates \
    DOCKERIZE_VERSION=v0.6.1

# Configuration variables
ENV SERVER_ADMIN=hostmaster@example.com \
    SERVER_NAME=example.com \
    SSL_ENABLED=true \
    SSL_EXPECT_CT_REPORT_URI= \
    SSL_EXPECT_CT_ENFORCE=false \
    SSL_EXPECT_CT_MAX_AGE=300

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Install dockerize (used in entryscripts)
RUN curl --silent --location https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz | tar -C /usr/local/bin -xzv

# Add links to volumes
RUN ln -s /certs /usr/local/apache2/conf/certs && \
    ln -s /vhosts /usr/local/apache2/conf/extra/vhosts

VOLUME /certs /vhosts

# Add templates
COPY ["templates/*", "${TEMPLATE_PATH}/"]

# Add entryscripts
COPY ["docker-apache-entrypoint.sh", "/usr/local/bin/docker-apache-entrypoint"]

ENTRYPOINT ["docker-apache-entrypoint"]
CMD ["httpd-foreground"]
