# syntax=docker/dockerfile:1.8.0@sha256:d6d396f3780b1dd56a3acbc975f57bd2fc501989b50164c41387c42d04e780d0

FROM alpine:3.20.0@sha256:77726ef6b57ddf65bb551896826ec38bc3e53f75cdde31354fbffb4f25238ebd

# renovate: datasource=github-tags depName=openssl/openssl
ENV OPENSSL_VERSION=3.3.1
ENV OPENSSL_SHA256=777cd596284c883375a2a7a11bf5d2786fc5413255efab20c50d6ffe6d020b7e
ENV OPENSSL_FILE=https://www.openssl.org/source/

ARG DEBIAN_FRONTEND=noninteractive

ADD --checksum=sha256:$OPENSSL_SHA256 $OPENSSL_FILE/openssl-$OPENSSL_VERSION.tar.gz /tmp/src/

WORKDIR /tmp/src

RUN build_deps="build-base linux-headers perl" && \
    apk update && apk upgrade && \
    apk add --no-cache $build_deps && \
    tar xzf openssl-$OPENSSL_VERSION.tar.gz && \
    cd openssl-$OPENSSL_VERSION && \
    ./config \
    --prefix=/opt/openssl \
    --openssldir=/opt/openssl \
    no-weak-ssl-ciphers \
    no-ssl3 \
    no-shared \
    enable-ec_nistp_64_gcc_128 \
    -DOPENSSL_NO_HEARTBEATS \
    -DOPENSSL_TLS_SECURITY_LEVEL=2 \
    -fstack-protector-strong && \
    nproc | xargs -I % make -j% && \
    nproc | xargs -I % make -j% install_sw && \
    apk del -r $build_deps && \
    rm -rf /tmp/*

WORKDIR /opt/openssl

CMD [ "/bin/sh" ]
