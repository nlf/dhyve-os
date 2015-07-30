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

RUN mkdir -p /build
ENV BUILDROOT_VERSION 20150729
RUN curl -L -o /build/buildroot.tar.bz2 http://buildroot.uclibc.org/downloads/snapshots/buildroot-$BUILDROOT_VERSION.tar.bz2 && \
    cd /build && \
    tar xf buildroot.tar.bz2 && \
    rm /build/buildroot.tar.bz2

COPY config/buildroot /build/buildroot/.config
COPY config /build/config

RUN cd /build/buildroot && make oldconfig && make source

# Copy our custom overlay
ENV ROOTFS /overlay
ENV VERSION 2.0.0
RUN echo $VERSION > $ROOTFS/etc/version
COPY rootfs $ROOTFS

# Add docker to our overlay
RUN mkdir -p $ROOTFS/usr/local/bin
ENV DOCKER_VERSION 1.7.1
RUN curl -L -o $ROOTFS/usr/local/bin/docker https://get.docker.io/builds/Linux/x86_64/docker-$DOCKER_VERSION && \
    chmod +x $ROOTFS/usr/local/bin/docker && \
    { $ROOTFS/usr/local/bin/docker version || true; }

# Install the build script
COPY bin/build_dhyve /usr/bin/

# Get the git versioning info
COPY .git /git/.git
RUN cd /git && \
    GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD) && \
    GITSHA1=$(git rev-parse --short HEAD) && \
    DATE=$(date) && \
    echo "${GIT_BRANCH} : ${GITSHA1} - ${DATE}" > $ROOTFS/etc/dhyve

VOLUME /build/buildroot/ccache
CMD ["/usr/bin/build_dhyve"]
