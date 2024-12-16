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
RUN git clone -b master https://github.com/yandex/odyssey.git && \
    cd odyssey && \
    ls -la && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release \
          -DPostgreSQL_TYPE_INCLUDE_DIR=/usr/include/postgresql \
          .. && \
    make && \
    ls -la  # Check where binary is created

# Final stage
FROM ubuntu:20.04

RUN apt-get update && \
    apt-get install -y \
    libssl1.1 \
    libpq5 \
    && rm -rf /var/lib/apt/lists/*

# Copy binary using correct path after checking ls output
COPY --from=builder /build/odyssey/build/sources/odyssey /usr/local/bin/
COPY config/odyssey.conf /etc/odyssey/odyssey.conf

WORKDIR /etc/odyssey

EXPOSE 6432

CMD ["odyssey", "/etc/odyssey/odyssey.conf"]