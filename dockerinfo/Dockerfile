FROM ubuntu:24.04

LABEL maintainer="arstrand@alstranded.com" \
      version="1.0" \
      description="Ubuntu image for Github Actions"

RUN apt-get update && \
    apt-get install -y libspdlog-dev git && \
    echo "Done"
