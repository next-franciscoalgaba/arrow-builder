# Set Python version
ARG PYTHON_VERSION=3.6

# From Official Python Image
FROM python:${PYTHON_VERSION}-slim-buster

# Set versions
ARG ARROW_VERSION=0.15.0
ARG ARROW_SHA1=2ede75769e12df972f0acdfddd53ab15d11e0ac2
ARG ARROW_BUILD_TYPE=release
ARG NUMPY_VERSION=1.16.4

# Set environment variables
ENV ARROW_HOME=/usr/local \
    PARQUET_HOME=/usr/local \
    LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

# Install dependencies
RUN apt-get update && \
    apt-get install -qq --no-install-recommends -y \
    git \
    wget \
    curl \
    flex \
    openssl \   
    autoconf \
    automake \
    libtool \ 
    unzip \
    bison \
    libcurl4-openssl-dev \
    libssl-dev \
    libgtest-dev \
    lcov \
    protobuf-compiler \
    software-properties-common \
    dpkg-dev \
    debhelper \
    g++ \
    cmake \
    libxml2-dev \
    uuid-dev \
    protobuf-compiler \
    libprotobuf-dev \
    libgsasl7-dev \
    libkrb5-dev \
    libboost-all-dev \
 && pip --no-cache-dir install \
    six \
    pytest \
    numpy==${NUMPY_VERSION} \
    cython \
    pandas \
 && rm -rf /var/lib/apt/lists/* \
 && apt-get clean
    
# Download, build apache-arrow and pyArrow
RUN mkdir /arrow \
    && curl -o /tmp/apache-arrow.tar.gz -SL https://github.com/apache/arrow/archive/apache-arrow-${ARROW_VERSION}.tar.gz \
    && echo "${ARROW_SHA1} *apache-arrow.tar.gz" | sha1sum /tmp/apache-arrow.tar.gz \
    && tar -xvf /tmp/apache-arrow.tar.gz -C /arrow --strip-components 1 \
    && mkdir -p /arrow/cpp/build \
    && cd /arrow/cpp/build \
    && cmake -DCMAKE_BUILD_TYPE=${ARROW_BUILD_TYPE} \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DCMAKE_INSTALL_PREFIX=${ARROW_HOME} \
    -DARROW_PARQUET=on \
    -DARROW_PYTHON=on \
    -DARROW_PLASMA=on \
    -DARROW_BUILD_TESTS=on \
    .. \
    && make -j$(nproc) \
    && make install