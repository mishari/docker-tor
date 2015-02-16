FROM ubuntu
MAINTAINER "Patrick O'Doherty <p@trickod.com>"

EXPOSE 9001
ENV VERSION 0.2.5.10

RUN apt-get update && apt-get install -y \
   build-essential \
   curl \
   libevent-2.0-5 \
   libssl1.0.0 \
   libevent-dev \
   libssl-dev

RUN curl https://dist.torproject.org/tor-${VERSION}.tar.gz | tar xz -C /tmp

RUN cd /tmp/tor-${VERSION} && ./configure
RUN cd /tmp/tor-${VERSION} && make
RUN cd /tmp/tor-${VERSION} && make install

ADD ./torrc /etc/torrc
# Allow you to upgrade your relay without having to regenerate keys
VOLUME /.tor

RUN apt-get -y remove build-essential libevent-dev libssl-dev
RUN apt-get -y autoremove


# Generate a random nickname for the relay
RUN echo "Nickname docker$(head -c 16 /dev/urandom  | sha1sum | cut -c1-10)" >> /etc/torrc

CMD /usr/local/bin/tor -f /etc/torrc

