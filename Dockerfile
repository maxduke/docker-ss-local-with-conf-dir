FROM alpine:3.10
MAINTAINER MaxDuke <maxduke@gmail.com>

ARG TZ='Asia/Shanghai'

ENV TZ ${TZ}
ENV SS_LIBEV_VERSION v3.3.5
ENV V2RAY_PLUGIN_VERSION v1.3.1
ENV SS_DOWNLOAD_URL https://github.com/shadowsocks/shadowsocks-libev.git 
ENV SS_DIR shadowsocks-libev-$SS_VER
ENV PLUGIN_OBFS_DOWNLOAD_URL https://github.com/shadowsocks/simple-obfs.git
ENV PLUGIN_V2RAY_DOWNLOAD_URL https://github.com/shadowsocks/v2ray-plugin/releases/download/${V2RAY_PLUGIN_VERSION}/v2ray-plugin-linux-amd64-${V2RAY_PLUGIN_VERSION}.tar.gz
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
      mbedtls-dev \
      pcre-dev \
      tar \
      git \
 # Linux Header
 && curl -sSL ${LINUX_HEADERS_DOWNLOAD_URL} > /linux-headers-4.4.6-r2.apk \
 && apk add --virtual .build-deps-kernel /linux-headers-4.4.6-r2.apk \
 # ss-libev
 && git clone ${SS_DOWNLOAD_URL} \
 && (cd shadowsocks-libev \
 && git checkout tags/${SS_LIBEV_VERSION} -b ${SS_LIBEV_VERSION} \
 && git submodule update --init --recursive \
 && ./autogen.sh \
 && ./configure --prefix=/usr --disable-documentation \
 && make install) \
 # simple-obfs
 && git clone ${PLUGIN_OBFS_DOWNLOAD_URL} \
 && (cd simple-obfs \
 && git submodule update --init --recursive \
 && ./autogen.sh \
 && ./configure --disable-documentation \
 && make install) \
 # v2ray-plugin
 && curl -o v2ray_plugin.tar.gz -sSL ${PLUGIN_V2RAY_DOWNLOAD_URL} \
 && tar -zxf v2ray_plugin.tar.gz \
 && mv v2ray-plugin_linux_amd64 /usr/bin/v2ray-plugin \
 # Set timezone and user
 && ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime \
 && echo ${TZ} > /etc/timezone \
 && adduser -h /tmp -s /sbin/nologin -S -D -H shadowsocks \
 # Runtime dependencies setup
 && apk add --no-cache \
      ca-certificates \
      rng-tools \
      $(scanelf --needed --nobanner /usr/bin/ss-* /usr/local/bin/obfs-* \
      | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
      | sort -u) \
 && cd .. \
 # Cleanup
 && apk del .build-deps .build-deps-kernel \
 && rm -rf /linux-headers-4.4.6-r2.apk \
        shadowsocks-libev \
        simple-obfs \
        v2ray_plugin.tar.gz \
        /etc/service \
        /var/cache/apk/* \
 && chmod +x /entrypoint.sh

VOLUME ["/ss-local/conf"]

ENTRYPOINT ["/entrypoint.sh"]
