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

WORKDIR /build/odyssey

RUN cmake -S $PWD -Bbuild -DCMAKE_BUILD_TYPE=Release -DCC_FLAGS="-Wextra -Wstrict-aliasing" -DPostgreSQL_TYPE_INCLUDE_DIR=/usr/include/postgresql -DUSE_SCRAM=YES
RUN make -Cbuild -j8


# Final stage
FROM ubuntu:20.04

RUN apt-get update && \
    apt-get install -y \
    libssl1.1 \
    libpq5 \
    && rm -rf /var/lib/apt/lists/*

# We'll update this path after finding the binary
COPY --from=builder /build/odyssey/build/sources/odyssey /usr/local/bin/

RUN mkdir /etc/odyssey

COPY config/odyssey.conf /etc/odyssey/odyssey.conf

EXPOSE 6432

CMD ["odyssey", "/etc/odyssey/odyssey.conf"]