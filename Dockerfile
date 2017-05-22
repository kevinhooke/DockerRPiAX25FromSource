#
# Dockerfile to create an RPi Docker image including ax25 from source
#
# pass --build-arg MYCALL=yourcall-ssid where yourcall is your
# Amateur Radio callsign and SID is your packet radio SSID suffix for 
# this packet radio device, eg AB1ABC-1
#
# Kevin Hooke, May 2017
#
FROM resin/rpi-raspbian:latest

ARG MYCALL
RUN test -n "$MYCALL"

RUN apt-get update && \
    apt-get install build-essential autoconf automake libtool && \
    apt-get install libncurses-dev nano && \
    useradd -m -s /bin/bash pi && \
    adduser pi sudo && \
    echo "pi:raspberry" | chpasswd

WORKDIR /home/pi

COPY ax25-apps-0.0.8-rc4.tar.gz /home/pi/
COPY ax25-tools-0.0.10-rc4.tar.gz /home/pi
COPY libax25-0.0.12-rc4.tar.gz /home/pi/

RUN gunzip *.gz && \
    tar xvf ax25-apps-*.tar && \
    tar xvf ax25-tools-*.tar && \
    tar xvf libax25-*

WORKDIR /home/pi/libax25-0.0.12-rc4
RUN ./configure && \
    make && \
    make install

WORKDIR /home/pi/ax25-tools-0.0.10-rc4
RUN ./configure && \
    make && \
    make install

WORKDIR /home/pi/ax25-apps-0.0.8-rc4
RUN ./configure && \
    make && \
    make install

#copy libax25 to expected lib dir
RUN cp /usr/local/lib/libax25.so /usr/lib
RUN ldconfig

RUN mkdir -p /usr/local/etc/ax25

RUN echo "# portname callsign speed paclen window description\n\
1 $MYCALL 19200 255 3 TNCPi" > /usr/local/etc/ax25/axports

WORKDIR /homwe/pi
USER pi


