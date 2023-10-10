FROM debian:bookworm-slim as builder

ENV OPENSSL3_VERSION=openssl-3.0.11 \
	OPENSSL3_SOURCE=https://www.openssl.org/source/ \
	HIREDIS_VERSION=v1.2.0 \
	HIREDIS_SOURCE=https://github.com/redis/hiredis.git \
	NGHTTP2_VERSION=v1.56.0 \
	NGHTTP2_SOURCE=https://github.com/nghttp2/nghttp2.git \
	UNBOUND_VERSION=release-1.18.0 \
	UNBOUND_SOURCE=https://github.com/NLnetLabs/unbound.git \
	LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/lib/:/lib64/:/usr/local/lib/

WORKDIR /tmp/src

RUN build_deps="build-essential ca-certificates curl apt-utils dirmngr gnupg libidn2-0-dev gcc libc-dev make libexpat1-dev binutils bsdmainutils ca-certificates ldnsutils git automake libtool-bin autoconf pkg-config byacc flex bison" && \
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
	sed -e 's/@-static -s@/@-static -s@ -all-static/' -i Makefile.in && \
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
		--enable-fully-static \
		--disable-shared \
		CFLAGS="-O2" && \
	make install -j`nproc` && \
	strip /usr/local/sbin/unbound && strip /usr/local/sbin/unbound-control && \
	mkdir -p /opt/pack && \
	cd /opt/pack && \
	for f in $(ldd /usr/local/sbin/unbound | sed -n 's/.*\s\(\/.*\) .*/\1/p'); do \
		cp --parents "$f" . ;\
	done && \
	cp --parents /usr/local/sbin/unbound . && \
	cp --parents /usr/local/sbin/unbound-control .

FROM scratch

COPY --from=builder /opt/pack /

ENV PATH=/usr/local/sbin/

ENTRYPOINT [ "unbound" ]
