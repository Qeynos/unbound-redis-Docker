FROM alpine:latest

RUN apk update && \
    apk add gcc g++ make openssl-dev expat-dev hiredis-dev && \
    adduser -D unbound && \
    cd opt/ && \
    wget https://nlnetlabs.nl/downloads/unbound/unbound-1.14.0.tar.gz && \
    tar xvf unbound-1.14.0.tar.gz && \
    cd unbound-1.14.0/ && \
    ./configure --enable-cachedb --with-libhiredis --enable-tfo-client --disable-maintainer-mode --disable-dependency-tracking --disable-rpath --disable-option-checking --disable-silent-rules --prefix=/usr --exec-prefix=/usr --sysconfdir=/etc --loca>
    make install && \
    cd / && rm -rf /opt/* && \
    rm /usr/sbin/unbound-checkconf \
    /usr/sbin/unbound-anchor \
    /usr/sbin/unbound-host && \
    apk del gcc g++ make


ENTRYPOINT [ "unbound" ]
