# syntax=docker/dockerfile:1.11.1@sha256:10c699f1b6c8bdc8f6b4ce8974855dd8542f1768c26eb240237b8f1c9c6c9976

FROM alpine:3.21.2@sha256:56fa17d2a7e7f168a043a2712e63aed1f8543aeafdcee47c58dcffe38ed51099

# renovate: datasource=github-tags depName=openssl/openssl
ENV OPENSSL_VERSION=3.4.1
ENV OPENSSL_SHA256=e15dda82fe2fe8139dc2ac21a36d4ca01d5313c75f99f46c4e8a27709b7294bf
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
