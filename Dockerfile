FROM debian:10.2-slim AS build

ENV VERSION 0.17.1

RUN apt-get update -y && \
    apt-get install -y git build-essential libtool autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils python3 libboost-system-dev libboost-filesystem-dev libboost-chrono-dev libboost-test-dev libboost-thread-dev libdb-dev libdb++-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    mkdir -p /tmp/src && \
    cd /tmp/src && \
    git clone https://github.com/litecoin-project/litecoin.git . && \
    git checkout v${VERSION} && \
    ./autogen.sh && \
    ./configure --with-incompatible-bdb --prefix=/opt/litecoin-${VERSION} && \
    make && \
    make install


FROM debian:10.2-slim

ENV VERSION 0.17.1

ENV PATH /opt/litecoin-${VERSION}/bin:$PATH
ENV DATA "/data"

COPY --from=build /opt/litecoin-${VERSION}/ /opt/litecoin-${VERSION}/
COPY entrypoint.sh /

RUN echo /opt/litecoin-0.17.1/lib > /etc/ld.so.conf.d/litecoin.conf && \
    ldconfig && \
    apt-get update -y && \
    apt-get install -y libssl-dev libevent-dev libboost-system-dev libboost-filesystem-dev libboost-chrono-dev libboost-test-dev libboost-thread-dev libdb-dev libdb++-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    mkdir -p "${DATA}" && \
    chmod 700 "${DATA}" && \
    chmod 555 /entrypoint.sh

VOLUME ["/data"]

ENTRYPOINT ["/entrypoint.sh"]

CMD ["litecoind"]