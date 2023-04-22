FROM nginx:latest

MAINTAINER Frank Steiler <frank@steilerdev.de>
# Could also be 'stable'
ARG VERSION="2023-04-04"

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get -y upgrade && \
    apt-get install \
        --no-install-recommends \
        --fix-missing \
        --assume-yes \
            rsync inotify-tools vim ca-certificates wget && \
    apt-get clean autoclean && \
    apt-get autoremove && \
    rm -rf /var/lib/{apt,dpkg,cache,log} /tmp/* /var/tmp/*

# Installing dokuwiki and moving things around
RUN mkdir -p /site && rm -rf /site/* && \
    wget -O /site/dokuwiki.tgz https://download.dokuwiki.org/src/dokuwiki/dokuwiki-${VERSION}.tgz && \
    tar -xzvf /site/dokuwiki.tgz --strip-components=1 -C /site && \
    rm /site/dokuwiki.tgz && \
    mkdir /distro /data /conf && \
    mv /site/data /distro/ && \
    mv /site/conf /distro/

# Applying fs patch for assets
ADD rootfs.tar.gz /

# Making sure setup script will run
RUN chmod +x /docker-entrypoint.d/30_init-doku.sh

# Exposing volume for other containers
VOLUME /site /data /conf /static-docs