# based on: https://github.com/xu-cheng/latex-docker/blob/master/Dockerfile

FROM alpine:3.16.0 AS base

FROM base AS citrus_dev_machine

LABEL \
	org.opencontainers.image.title="Docker image for basic C++ development" \
	org.opencontainers.image.authors="Ben Vining" \
	org.opencontainers.image.source="https://github.com/benthevining/DevMachine" \
	org.opencontainers.image.licenses="GPL-3"

ARG apk_version=edge

RUN apk update && apk upgrade

# Install system packages
RUN \
	apk --no-cache add \
	--repository=http://dl-cdn.alpinelinux.org/alpine/$apk_version/main \
		bash=5.1.16-r2 \
		binutils=2.38-r2 \
		ccache=4.6.1-r0 \
		clang=13.0.1-r1 \
		cmake=3.23.2-r0 \
		doxygen=1.9.4-r0 \
		gcc=11.2.1_git20220219-r2 \
		g++=11.2.1_git20220219-r2 \
		git=2.36.1-r0 \
		make=4.3-r0 \
		musl-dev=1.2.3-r0 \
		musl-utils=1.2.3-r0 \
		python3=3.10.4-r0 \
		ruby=3.1.2-r0

COPY requirements.txt /tmp/requirements.txt

RUN python3 -m ensurepip --upgrade

# Install Python packages
RUN python3 -m pip install --no-cache-dir -r /tmp/requirements.txt && \
	rm -rf /tmp/requirements.txt

# export CMake variables
ENV CC=/usr/bin/cc
ENV CXX=/usr/bin/gcc
ENV CMAKE_C_COMPILER=$CC
ENV CMAKE_CXX_COMPILER=$CXX
ENV CMAKE_GENERATOR="Ninja Multi-Config"

# copy over healthcheck file
COPY test.cpp /healthcheck/test.cpp

WORKDIR /

ENTRYPOINT ["/bin/bash"]

HEALTHCHECK --interval=10800s --retries=1 CMD \
	clang++ /healthcheck/test.cpp && \
	gcc -lstdc++ /healthcheck/test.cpp
