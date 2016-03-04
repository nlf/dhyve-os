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

ENV BUILDROOT_VERSION 2016.02
RUN wget -qO- http://buildroot.uclibc.org/downloads/buildroot-$BUILDROOT_VERSION.tar.bz2 | tar xj && \
    mv buildroot-$BUILDROOT_VERSION /tmp/buildroot

RUN ln -s /tmp/config/buildroot /tmp/buildroot/.config

WORKDIR /tmp/buildroot
