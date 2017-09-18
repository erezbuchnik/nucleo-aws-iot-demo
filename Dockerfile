
FROM ubuntu
MAINTAINER Erez Buchnik <erez@shrewdthings.com>

# Copy in the source
COPY . /src/nucleo-aws-iot-demo-docker/

WORKDIR /src/nucleo-aws-iot-demo-docker

