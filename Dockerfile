FROM php:7.1-apache

# Utilities
RUN apt-get update && \
    apt-get -y install apt-transport-https git curl vim --no-install-recommends && \
    rm -r /var/lib/apt/lists/*

# SimpleSAMLphp
ARG SIMPLESAMLPHP_VERSION=1.15.2

COPY metadata/metadata.patch /tmp/
RUN curl -s -L -o /tmp/simplesamlphp.tar.gz https://github.com/simplesamlphp/simplesamlphp/releases/download/v$SIMPLESAMLPHP_VERSION/simplesamlphp-$SIMPLESAMLPHP_VERSION.tar.gz && \
    tar xzf /tmp/simplesamlphp.tar.gz -C /tmp && \
    rm -f /tmp/simplesamlphp.tar.gz  && \
    mv /tmp/simplesamlphp-* /var/www/simplesamlphp && \
    touch /var/www/simplesamlphp/modules/exampleauth/enable && \
    sed --in-place 's/BINDING_HTTP_REDIRECT/BINDING_HTTP_POST/' /var/www/simplesamlphp/lib/SimpleSAML/Configuration.php && \

    patch -i /tmp/metadata.patch /var/www/simplesamlphp/lib/SimpleSAML/Metadata/MetaDataStorageHandler.php && \
    apt update && \
    apt install -y python3 && \
    apt install -y python3-pip && \
    python3 -m pip install -U jsonschema && \
    python3 -m pip install -U readerwriterlock

COPY config/simplesamlphp/config.php /var/www/simplesamlphp/config
COPY config/simplesamlphp/authsources.php /var/www/simplesamlphp/config
COPY config/simplesamlphp/saml20-sp-remote.php /var/www/simplesamlphp/metadata
COPY config/simplesamlphp/server.crt /var/www/simplesamlphp/cert/
COPY config/simplesamlphp/server.pem /var/www/simplesamlphp/cert/

# Apache
COPY config/apache/ports.conf /etc/apache2
COPY config/apache/simplesamlphp.conf /etc/apache2/sites-available
COPY config/apache/cert.crt /etc/ssl/cert/cert.crt
COPY config/apache/private.key /etc/ssl/private/private.key
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf && \
    a2enmod ssl && \
    a2dissite 000-default.conf default-ssl.conf && \
    a2ensite simplesamlphp.conf

RUN apt update -y && apt upgrade -y && apt install -y python3 && apt install -y python3-pip && pip3 install readerwriterlock

COPY config/run-services.sh /var/www/simplesamlphp/config/run-services.sh


ENTRYPOINT ["/var/www/simplesamlphp/config/run-services.sh"]
CMD ["/bin/bash", "-c", "/var/www/simplesamlphp/config/run-services.sh"]

# Set work dir
WORKDIR /var/www/simplesamlphp

# General setup
EXPOSE 8080 8443 8000