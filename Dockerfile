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
    postgresql-server-dev-all \  # Thêm package này
    pkg-config \                 # Thêm package này
    && rm -rf /var/lib/apt/lists/*

# Clone specific version để tránh breaking changes
RUN git clone -b master https://github.com/yandex/odyssey.git && \
    cd odyssey && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release \
          -DPostgreSQL_TYPE_INCLUDE_DIR=/usr/include/postgresql \  # Chỉ định PostgreSQL include dir
          .. && \
    make && \
    make install

WORKDIR /odyssey
EXPOSE 6432

CMD ["odyssey", "/etc/odyssey/odyssey.conf"]