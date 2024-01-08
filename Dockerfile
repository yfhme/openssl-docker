# syntax=docker/dockerfile:1@sha256:ac85f380a63b13dfcefa89046420e1781752bab202122f8f50032edf31be0021

FROM alpine:3.19.0@sha256:51b67269f354137895d43f3b3d810bfacd3945438e94dc5ac55fdac340352f48

# renovate: datasource=github-tags depName=openssl/openssl
ENV OPENSSL_VERSION=3.2.0
ENV OPENSSL_SHA256=14c826f07c7e433706fb5c69fa9e25dab95684844b4c962a2cf1bf183eb4690e
ENV OPENSSL_FILE=https://www.openssl.org/source/

ARG DEBIAN_FRONTEND=noninteractive

ADD --checksum=sha256:$OPENSSL_SHA256 $OPENSSL_FILE/openssl-$OPENSSL_VERSION.tar.gz /tmp/src/

WORKDIR /tmp/src

RUN build_deps="build-base linux-headers perl" && \
    apk update && apk upgrade && \
    apk add $build_deps && \
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

ENTRYPOINT /bin/sh