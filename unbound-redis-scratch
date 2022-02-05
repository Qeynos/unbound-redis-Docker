FROM debian:bullseye as openssl
LABEL maintainer="Matthew Vance"

ENV VERSION_OPENSSL=openssl-3.0.1 \
    SHA256_OPENSSL=c311ad853353bce796edad01a862c50a8a587f62e7e2100ef465ab53ec9b06d1 \
    SOURCE_OPENSSL=https://www.openssl.org/source/ \
    OPGP_OPENSSL=8657ABB260F056B1E5190839D9C4D26D0E604491

WORKDIR /tmp/src

RUN set -e -x && \
    build_deps="build-essential ca-certificates curl dirmngr gnupg libidn2-0-dev libssl-dev" && \
    DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y --no-install-recommends \
      $build_deps && \
    curl -L $SOURCE_OPENSSL$VERSION_OPENSSL.tar.gz -o openssl.tar.gz && \
    echo "${SHA256_OPENSSL} ./openssl.tar.gz" | sha256sum -c - && \
    curl -L $SOURCE_OPENSSL$VERSION_OPENSSL.tar.gz.asc -o openssl.tar.gz.asc && \
    GNUPGHOME="$(mktemp -d)" && \
    export GNUPGHOME && \
    gpg --no-tty --keyserver keys.openpgp.org --recv-keys "$OPGP_OPENSSL" && \
    gpg --batch --verify openssl.tar.gz.asc openssl.tar.gz && \
    tar xzf openssl.tar.gz && \
    cd $VERSION_OPENSSL && \
    ./config \
      --prefix=/opt/openssl \
      --openssldir=/opt/openssl \
      no-weak-ssl-ciphers \
      no-ssl3 \
      no-shared \
      enable-ec_nistp_64_gcc_128 \
      -DOPENSSL_NO_HEARTBEATS \
      -fstack-protector-strong && \
    make depend && \
    make && \
    make install_sw && \
    apt-get purge -y --auto-remove \
      $build_deps && \
    rm -rf \
        /tmp/* \
        /var/tmp/* \
        /var/lib/apt/lists/*

FROM debian:bullseye as unbound
LABEL maintainer="Matthew Vance"

ENV NAME=unbound \
    UNBOUND_VERSION=1.14.0 \
    UNBOUND_SHA256=6ef91cbf02d5299eab39328c0857393de7b4885a2fe7233ddfe3c124ff5a89c8 \
    UNBOUND_DOWNLOAD_URL=https://nlnetlabs.nl/downloads/unbound/unbound-1.14.0.tar.gz

WORKDIR /tmp/src

COPY --from=openssl /opt/openssl /opt/openssl

RUN build_deps="curl gcc libc-dev libevent-dev libexpat1-dev libnghttp2-dev make" && \
    set -x && \
    DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y --no-install-recommends \
      $build_deps \
      binutils \
      bsdmainutils \
      ca-certificates \
      ldnsutils \
      libhiredis-dev \
      libevent-2.1-7 \
      libexpat1 
#RUN apt install git -y
#RUN cd /tmp && git clone -b v1.0.2 https://github.com/redis/hiredis.git && \
#    cd hiredis && \
#    make install
#RUN cd /tmp && git clone --depth 1 --branch release-2.1.12-stable https://github.com/libevent/libevent  && \
#    cd libevent && \
#    ./configure && \
#    make install
RUN curl -sSL $UNBOUND_DOWNLOAD_URL -o unbound.tar.gz && \
    echo "${UNBOUND_SHA256} *unbound.tar.gz" | sha256sum -c - && \
    tar xzf unbound.tar.gz && \
    rm -f unbound.tar.gz && \
    cd unbound-1.14.0 && \
    groupadd unbound && \
    useradd -g unbound -s /etc -d /dev/null unbound && \
    ./configure \
#        --enable-fully-static \
        --with-libhiredis \
        --with-conf-file=/etc/unbound/unbound.conf \
        --with-pthreads \
        --with-username="" \
        --with-ssl=/opt/openssl \
        --with-libevent \
        --with-libnghttp2 \
        --disable-flto \
        --enable-tfo-server \
        --enable-tfo-client \
        --enable-cachedb \
        --disable-maintainer-mode \
        --disable-rpath \
        --disable-option-checking \
        --disable-silent-rules \
        --disable-gtk-doc \
        --disable-gtk-doc-html \
        --disable-doc \
        --disable-docs \
        --disable-documentation \
        --with-xmlto=no \
        --enable-ipv6 \
        --disable-nls \
        --enable-shared \
        --disable-rpath \
        --disable-debug \
        --enable-event-api \ 
        CFLAGS="-Os" && \
#        LDFLAGS=-static && \
    make install && \
    apt-get purge -y --auto-remove \
      $build_deps && \
    rm -rf \
        /usr/local/share/ \
        /tmp/* \
        /var/tmp/* \
        /var/lib/apt/lists/*
RUN    strip /usr/local/sbin/unbound && strip /usr/local/sbin/unbound-control 
RUN    mkdir -p /tmp/root && \
    cd /tmp/root && \
    for f in $(ldd /usr/local/sbin/unbound | sed -n 's/.*\s\(\/.*\) .*/\1/p'); do \
       cp --parents "$f" . ;\
    done && \
    cp --parents /lib/*/ld-2.31.so . && \
    cp --parents /lib/*/libnss*.so.2 . && \
    cp --parents /lib/*/libresolv*.so.2 . && \
    cd ..
RUN    mkdir /tmp/unbound/ && \
       cp /usr/local/sbin/unbound /tmp/unbound && cp /usr/local/sbin/unbound-control /tmp/unbound

FROM scratch

#FROM debian:bullseye

COPY --from=unbound /tmp/unbound /
COPY --from=unbound /tmp/root/ /

ENV LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu/:/lib/x86_64-linux-gnu/:/lib64/     
ENV PATH=/
ENTRYPOINT [ "unbound" ]
