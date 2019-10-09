FROM alpine:latest
MAINTAINER MaxDuke <maxduke@gmail.com>

COPY root/ /

RUN set -ex \
 # Build environment setup
 && apk add --no-cache --virtual .build-deps \
      autoconf \
      automake \
      build-base \
      c-ares-dev \
      libev-dev \
      libtool \
      libsodium-dev \
      linux-headers \
      mbedtls-dev \
      pcre-dev \
 # Download latest repo
 && wget --no-check-certificate https://github.com/shadowsocks/shadowsocks-libev/archive/master.zip -O shadowsocks-libev.zip \
 && unzip shadowsocks-libev.zip \
 # Build & install
 && cd shadowsocks-libev-master \
 && ./autogen.sh \
 && ./configure --prefix=/usr --disable-documentation \
 && make install \
 && apk del .build-deps \
 # Runtime dependencies setup
 && apk add --no-cache \
      ca-certificates \
      rng-tools \
      $(scanelf --needed --nobanner /usr/bin/ss-* \
      | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
      | sort -u) \
 && rm -rf shadowsocks-libev.zip shadowsocks-libev-master \
 && chmod +x /entrypoint.sh

USER nobody

VOLUME ["/ss-local/conf"]

ENTRYPOINT ["/entrypoint.sh"]
