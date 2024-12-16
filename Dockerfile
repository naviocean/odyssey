# Build stage
FROM ubuntu:20.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
    git \
    build-essential \
    cmake \
    libssl-dev \
    postgresql-client \
    libpq-dev \
    postgresql-server-dev-all \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# Split commands and add logging
RUN git clone -b master https://github.com/yandex/odyssey.git
RUN cd odyssey && \
    ls -la && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release \
          -DPostgreSQL_TYPE_INCLUDE_DIR=/usr/include/postgresql \
          .. && \
    make && \
    find . -name "odyssey" -type f  # Find the binary
RUN pwd && ls -R /build  # List all files in build directory

# Final stage
FROM ubuntu:20.04

RUN apt-get update && \
    apt-get install -y \
    libssl1.1 \
    libpq5 \
    && rm -rf /var/lib/apt/lists/*

# We'll update this path after finding the binary
COPY --from=builder /build/odyssey/build/odyssey /usr/local/bin/
COPY config/odyssey.conf /etc/odyssey/odyssey.conf

WORKDIR /etc/odyssey

EXPOSE 6432

CMD ["odyssey", "/etc/odyssey/odyssey.conf"]