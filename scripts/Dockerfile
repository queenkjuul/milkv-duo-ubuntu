FROM ubuntu:noble

ENV DOCKER_BUILD=true

RUN mkdir /project
WORKDIR /project
COPY setup.sh /project/
RUN /project/setup.sh
RUN git clone https://github.com/pengutronix/genimage
WORKDIR /project/genimage
RUN ./autogen.sh && ./configure && make && make install
WORKDIR /project