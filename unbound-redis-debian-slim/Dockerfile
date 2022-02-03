FROM debian:bullseye-slim

RUN apt update && apt install -y gcc g++ wget ca-certificates make libssl-dev libexpat1-dev libhiredis-dev  --no-install-recommends &&\
    adduser -q --disabled-password unbound && \
    cd opt/ && \
    wget https://nlnetlabs.nl/downloads/unbound/unbound-1.14.0.tar.gz && \
    tar xvf unbound-1.14.0.tar.gz && \
    cd unbound-1.14.0/ && \
    ./configure \
        --enable-cachedb \
        --with-libhiredis \
        --enable-tfo-client \
        --disable-maintainer-mode \
        --disable-dependency-tracking \
        --disable-rpath \
        --disable-option-checking \
        --disable-silent-rules \
        --prefix=/usr \
        --exec-prefix=/usr \
        --sysconfdir=/etc \
        --localstatedir=/var \
        --disable-gtk-doc \
        --disable-gtk-doc-html \
        --disable-doc \
        --disable-docs \
        --disable-documentation \
        --with-xmlto=no \
        --with-fop=no \
        --disable-dependency-tracking \
        --enable-ipv6 \
        --disable-nls \
        --disable-static \
        --enable-shared \
        --disable-rpath \
        --disable-debug \
        --with-conf-file=/etc/unbound/unbound.conf \
        --with-pidfile=/var/run/unbound.pid \
        --with-rootkey-file=/etc/unbound/root.key && \
    make install && \
    cd / && rm -rf /opt/* && \
    rm /usr/sbin/unbound-checkconf \
    /usr/sbin/unbound-anchor \
    /usr/sbin/unbound-host && \
    apt-get purge -y --auto-remove gcc g++ wget ca-certificates make && \
        rm -rf \
        /tmp/* \
        /var/tmp/* \
        /var/lib/apt/lists/*

ENTRYPOINT [ "unbound" ]
