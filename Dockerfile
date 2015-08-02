FROM ubuntu:14.04.2

RUN apt-get update && apt-get install -y unzip \
                        bc \
                        wget \
                        python \
                        xz-utils \
                        curl \
                        git \
                        build-essential \
                        cpio

ENV ROOTFS /overlay

RUN mkdir -p /build
ENV BUILDROOT_VERSION 20150729
RUN curl -L -o /build/buildroot.tar.bz2 http://buildroot.uclibc.org/downloads/snapshots/buildroot-$BUILDROOT_VERSION.tar.bz2 && \
    cd /build && \
    tar xf buildroot.tar.bz2 && \
    rm /build/buildroot.tar.bz2

# Add docker to our overlay
RUN mkdir -p $ROOTFS/usr/local/bin
ENV DOCKER_VERSION 1.7.1
RUN curl -L -o $ROOTFS/usr/local/bin/docker https://get.docker.io/builds/Linux/x86_64/docker-$DOCKER_VERSION && \
    chmod +x $ROOTFS/usr/local/bin/docker

# Copy our custom overlay
ENV VERSION 1.0.2
COPY rootfs $ROOTFS
RUN echo $VERSION > $ROOTFS/etc/version

# Install the build script
COPY bin/build_dhyve /usr/bin/
COPY config/buildroot /build/buildroot/.config
COPY config /build/config

# Get the git versioning info
COPY .git /git/.git
RUN cd /git && \
    GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD) && \
    GITSHA1=$(git rev-parse --short HEAD) && \
    DATE=$(date) && \
    echo "${GIT_BRANCH} : ${GITSHA1} - ${DATE}" > $ROOTFS/etc/dhyve && \
    rm -rf /git

VOLUME /build/buildroot/ccache
VOLUME /build/buildroot/dl

CMD ["/usr/bin/build_dhyve"]
