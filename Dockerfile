FROM debian:10.5-slim

ENV VERSION 0.18.1

RUN apt-get update -y && \
    apt-get install -y curl gnupg && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    curl -SL https://download.litecoin.org/litecoin-${VERSION}/linux/litecoin-${VERSION}-x86_64-linux-gnu.tar.gz | tar xvz -C /opt

ENV PATH /opt/litecoin-${VERSION}/bin:$PATH
ENV DATA "/data"

COPY entrypoint.sh /

VOLUME ["/data"]

ENTRYPOINT ["/entrypoint.sh"]

CMD ["litecoind"]