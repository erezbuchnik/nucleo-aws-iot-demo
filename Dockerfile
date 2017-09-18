
FROM ubuntu
MAINTAINER Erez Buchnik <erez@shrewdthings.com>

RUN apt -y update

# Install Node.js:
RUN curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
RUN apt -y install nodejs
RUN apt -y install build-essential

# Copy in the source:
COPY ./ /src/nucleo-aws-iot-demo-docker/

WORKDIR /src/nucleo-aws-iot-demo-docker

