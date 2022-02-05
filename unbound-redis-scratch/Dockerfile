FROM debian:bullseye as unbound
LABEL maintainer="Matthew Vance"

ENV VERSION_OPENSSL=openssl-3.0.1 \
    SHA256_OPENSSL=c311ad853353bce796edad01a862c50a8a587f62e7e2100ef465ab53ec9b06d1 \
    SOURCE_OPENSSL=https://www.openssl.org/source/ \
    OPGP_OPENSSL=8657ABB260F056B1E5190839D9C4D26D0E604491

WORKDIR /tmp/src

RUN set -e -x && \
    build_deps="build-essential ca-certificates curl dirmngr gnupg libidn2-0-dev" && \
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
    make CFLAGS="-O2" && \
    make install_sw

WORKDIR /tmp/src

ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib/:/lib/:/lib64/:/usr/local/lib/
ENV PKG_CONFIG_PATH=/opt/openssl1/lib/pkgconfig/
RUN build_deps="curl gcc libc-dev make libexpat1-dev" && \
    set -x && \
    DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y --no-install-recommends \
      $build_deps \
      binutils \
      bsdmainutils \
      ca-certificates \
      ldnsutils
RUN apt install git automake wget libtool-bin autoconf pkg-config apt-utils python python-setuptools byacc -y
RUN openssl_version='1.1.1m' && wget https://www.openssl.org/source/openssl-"$openssl_version".tar.gz && \
    tar xvf openssl-"$openssl_version".tar.gz && \
    cd openssl-"$openssl_version" && \
    ./config --prefix=/opt/openssl1 --openssldir=/opt/openssl1 no-shared CFLAGS="-O2" && \
    make -j`nproc` && make install_sw -j`nproc`
ENV PKG_CONFIG_PATH=/opt/openssl1/lib/pkgconfig
RUN cd /tmp && git clone  --depth 1 --branch v1.0.2 https://github.com/redis/hiredis.git && \
    cd hiredis && \
    make install
RUN cd /tmp && git clone --depth 1 --branch release-2.1.12-stable https://github.com/libevent/libevent  && \
    cd libevent && \
    ./autogen.sh && \
    ./configure CFLAGS="-O2 $(pkg-config --cflags openssl)" LIBS="$(pkg-config --libs --static openssl)" && \
    make install
RUN cd /tmp && git clone --depth 1 --branch v1.46.0 https://github.com/nghttp2/nghttp2.git  && \
    cd nghttp2 && \
    autoreconf -i && \
    automake && \
    autoconf && \
    ./configure CFLAGS="-O2" && \
    make install
RUN cd /tmp && git clone --depth 1 --branch release-1.14.0 https://github.com/NLnetLabs/unbound.git  && \
    cd unbound && \
    ./configure \
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
        CFLAGS="-O2" && \
    make install

RUN strip /usr/local/sbin/unbound && strip /usr/local/sbin/unbound-control 
RUN mkdir -p /tmp/pack && \
    cd /tmp/pack && \
    for f in $(ldd /usr/local/sbin/unbound | sed -n 's/.*\s\(\/.*\) .*/\1/p'); do \
       cp --parents "$f" . ;\
    done && \
    cp --parents /lib/*/ld-2.31.so . && \
    cp --parents /lib/*/libnss*.so.2 . && \
    cp --parents /lib/*/libresolv*.so.2 . && \
    cp --parents /usr/local/sbin/unbound . && \
    cp --parents /usr/local/sbin/unbound-control .

FROM scratch

COPY --from=unbound /tmp/pack /

ENV LD_LIBRARY_PATH=/usr/lib/:/lib/:/lib64/:/usr/local/lib/
ENV PATH=/usr/local/sbin/
ENTRYPOINT [ "unbound" ]
