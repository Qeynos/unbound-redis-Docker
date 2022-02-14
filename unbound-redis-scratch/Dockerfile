FROM debian:stable-slim as builder

ENV OPENSSL3_VERSION=openssl-3.0.1 \
	OPENSSL3_SOURCE=https://www.openssl.org/source/ \
	HIREDIS_VERSION=v1.0.2 \
	HIREDIS_SOURCE=https://github.com/redis/hiredis.git \
	NGHTTP2_VERSION=v1.46.0 \
	NGHTTP2_SOURCE=https://github.com/nghttp2/nghttp2.git \
	UNBOUND_VERSION=release-1.15.0 \
	UNBOUND_SOURCE=https://github.com/NLnetLabs/unbound.git \
	LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/lib/:/lib64/:/usr/local/lib/

WORKDIR /tmp/src

RUN build_deps="build-essential ca-certificates curl apt-utils dirmngr gnupg libidn2-0-dev gcc libc-dev make libexpat1-dev binutils bsdmainutils ca-certificates ldnsutils git automake libtool-bin autoconf pkg-config python python-setuptools byacc" && \
	DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y --no-install-recommends \
		$build_deps && \
	git config --global advice.detachedHead false && \
	curl -L $OPENSSL3_SOURCE$OPENSSL3_VERSION.tar.gz -o $OPENSSL3_VERSION.tar.gz && \
	tar xzf $OPENSSL3_VERSION.tar.gz && \
	cd $OPENSSL3_VERSION && \
	./config \
		--prefix=/opt/openssl3 \
		--openssldir=/opt/openssl3 \
		no-weak-ssl-ciphers \
		no-ssl3 \
		no-shared \
		enable-ec_nistp_64_gcc_128 \
		-DOPENSSL_NO_HEARTBEATS \
		-fstack-protector-strong && \
	make depend -j`nproc` && \
	make -j`nproc` CFLAGS="-O2" && \
	make install_sw -j`nproc` && \
	cd / && git clone --depth 1 --branch $HIREDIS_VERSION $HIREDIS_SOURCE && \
	cd hiredis && \
	make CFLAGS="-O2" && make install -j`nproc` && \
	cd / && git clone --depth 1 --branch $NGHTTP2_VERSION $NGHTTP2_SOURCE && \
	cd nghttp2 && \
	autoreconf -i && \
	automake && \
	autoconf && \
	./configure CFLAGS="-O2" && \
	make install -j`nproc` && \
	cd / && git clone --depth 1 --branch $UNBOUND_VERSION $UNBOUND_SOURCE && \
	cd unbound && \
	./configure \
		--with-libhiredis \
		--with-conf-file=/etc/unbound/unbound.conf \
		--with-pthreads \
		--with-ssl=/opt/openssl3 \
		--with-libnghttp2 \
		--with-username="" \
		--enable-tfo-server \
		--enable-tfo-client \
		--enable-cachedb \
		--enable-event-api \ 
		--disable-maintainer-mode \
		--disable-option-checking \
		--disable-gtk-doc \
		--disable-gtk-doc-html \
		--disable-doc \
		--disable-docs \
		--disable-documentation \
		--disable-nls \
		--disable-debug \
		CFLAGS="-O2" && \
	make install -j`nproc` && \
	strip /usr/local/sbin/unbound && strip /usr/local/sbin/unbound-control && \
	mkdir -p /opt/pack && \
	cd /opt/pack && \
	for f in $(ldd /usr/local/sbin/unbound | sed -n 's/.*\s\(\/.*\) .*/\1/p'); do \
		cp --parents "$f" . ;\
	done && \
	cp --parents /lib/*/ld-2.31.so . && \
	cp --parents /lib/*/libnss*.so.2 . && \
	cp --parents /lib/*/libresolv*.so.2 . && \
	cp --parents /usr/local/sbin/unbound . && \
	cp --parents /usr/local/sbin/unbound-control . && \
	apt-get purge -y --auto-remove \
		$build_deps && \
	rm -rf \
		/tmp/* \
		/var/tmp/* \
		/var/lib/apt/lists/*

FROM scratch

COPY --from=builder /opt/pack /

ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/lib/:/lib64/:/usr/local/lib/ \
	PATH=/usr/local/sbin/

ENTRYPOINT [ "unbound" ]

#	PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/opt/openssl1/lib/pkgconfig/

#	OPENSSL1_VERSION=openssl-1.1.1m \
#	OPENSSL1_SOURCE=https://www.openssl.org/source/ \

#	LIBEVENT_VERSION=release-2.1.12-stable \
#	LIBEVENT_SOURCE=https://github.com/libevent/libevent \

# build openssl 1
#	cd / && curl -L $OPENSSL1_SOURCE$OPENSSL1_VERSION.tar.gz -o $OPENSSL1_VERSION.tar.gz && \
#	tar xvf $OPENSSL1_VERSION.tar.gz && \
#	cd $OPENSSL1_VERSION && \
#	./config --prefix=/opt/openssl1 --openssldir=/opt/openssl1 no-shared CFLAGS="-O2" && \
#	make -j`nproc` && make install_sw -j`nproc` && \

# build libevent
#	cd / && git clone --depth 1 --branch $LIBEVENT_VERSION $LIBEVENT_SOURCE && \
#	cd libevent && \
#	./autogen.sh && \
#	./configure CFLAGS="-O2 $(pkg-config --cflags openssl)" LIBS="$(pkg-config --libs --static openssl)" && \
#	make install -j`nproc` && \

#		--with-libevent \
