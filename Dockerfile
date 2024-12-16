FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
    git \
    build-essential \
    cmake \
    libssl-dev \
    postgresql-client \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/yandex/odyssey.git && \
    cd odyssey && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release .. && \
    make && \
    make install

EXPOSE 6432

CMD ["odyssey", "/etc/odyssey/odyssey.conf"]