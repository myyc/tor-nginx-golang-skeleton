FROM alpine:3

RUN apk add tor

ADD torrc /etc/tor/torrc
RUN mkdir /tor

RUN chmod 700 /tor

ENTRYPOINT [ "tor", "-f", "/etc/tor/torrc" ]
