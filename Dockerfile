FROM alpine:3.10
MAINTAINER MaxDuke <maxduke@gmail.com>

ARG TZ='Asia/Shanghai'

ENV TZ ${TZ}
ENV SS_VER 3.3.1
ENV SS_URL https://github.com/shadowsocks/shadowsocks-libev/archive/v$SS_VER.tar.gz
ENV SS_DIR shadowsocks-libev-$SS_VER
ENV LINUX_HEADERS_DOWNLOAD_URL=http://dl-cdn.alpinelinux.org/alpine/v3.7/main/x86_64/linux-headers-4.4.6-r2.apk


COPY root/ /

RUN set -ex \
 # Build environment setup
 && apk upgrade \
 && apk add bash tzdata \
 && apk add --no-cache --virtual .build-deps \
      autoconf \
      automake \
      build-base \
      c-ares-dev \
      curl \
      libev-dev \
      libtool \
      libsodium-dev \
      linux-headers \
      mbedtls-dev \
      pcre-dev \
      tar \
 # Linux Header
 && curl -sSL ${LINUX_HEADERS_DOWNLOAD_URL} > /linux-headers-4.4.6-r2.apk \
 && apk add --virtual .build-deps-kernel /linux-headers-4.4.6-r2.apk \
 # Download latest repo
 && curl -sSL $SS_URL | tar xz \
 && cd $SS_DIR \
     && curl -sSL https://github.com/shadowsocks/libbloom/archive/master.tar.gz | tar xz --strip 1 -C libbloom \
     && curl -sSL https://github.com/shadowsocks/ipset/archive/shadowsocks.tar.gz | tar xz --strip 1 -C libipset \
     && curl -sSL https://github.com/shadowsocks/libcork/archive/shadowsocks.tar.gz | tar xz --strip 1 -C libcork \
 # Build & install
 && ./autogen.sh \
 && ./configure --prefix=/usr --disable-documentation \
 && make install \
 && apk del .build-deps .build-deps-kernel \
 # Set timezone and user
 && ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime \
 && echo ${TZ} > /etc/timezone \
 && adduser -h /tmp -s /sbin/nologin -S -D -H shadowsocks \
 # Runtime dependencies setup
 && apk add --no-cache \
      ca-certificates \
      rng-tools \
      $(scanelf --needed --nobanner /usr/bin/ss-* \
      | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
      | sort -u) \
 && cd .. \
 && rm -rf $SS_DIR \
    /linux-headers-4.4.6-r2.apk \
    /etc/service \
    /var/cache/apk/* \
 && chmod +x /entrypoint.sh

VOLUME ["/ss-local/conf"]

ENTRYPOINT ["/entrypoint.sh"]
