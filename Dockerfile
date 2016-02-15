FROM debian

RUN echo "locales locales/locales_to_be_generated multiselect en_US.UTF-8 UTF-8" | debconf-set-selections && \
    echo "locales locales/default_environment_locale select en_US.UTF-8" | debconf-set-selections && \
    apt-get -q update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -q -y \
    wget \
    build-essential \
    libncurses-dev \
    rsync \
    unzip \
    bc \
    gnupg \
    python \
    libc6-i386 \
    cpio \
    locales \
    git-core

COPY rootfs /tmp/rootfs

ENV BUILDROOT_VERSION 2015.11.1
RUN wget -qO- http://buildroot.uclibc.org/downloads/buildroot-$BUILDROOT_VERSION.tar.bz2 | tar xj && \
    mv buildroot-$BUILDROOT_VERSION /tmp/buildroot

ENV DOCKER_VERSION 1.10.1
RUN wget -qO /tmp/rootfs/usr/bin/docker https://get.docker.io/builds/Linux/x86_64/docker-${DOCKER_VERSION} && \
    chmod +x /tmp/rootfs/usr/bin/docker

RUN ln -s /tmp/config/buildroot /tmp/buildroot/.config

WORKDIR /tmp/buildroot
