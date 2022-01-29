FROM alpine:latest

RUN apk update && \
    apk add gcc g++ make openssl-dev expat-dev hiredis-dev && \
    adduser -D unbound && \
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
    apk del gcc g++ make


ENTRYPOINT [ "unbound" ]
