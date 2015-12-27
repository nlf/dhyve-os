TARGETS := output/rootfs.cpio.xz output/bzImage
SOURCES := Dockerfile bin/build_dhyve \
	config/buildroot config/kernel config/user \
	rootfs/etc/default/docker \
	rootfs/etc/init.d/S03automount \
	rootfs/etc/init.d/S39hostname \
	rootfs/etc/init.d/S41automount-nfs \
	rootfs/etc/init.d/S51docker \
	rootfs/etc/init.d/S52sysctl \
	rootfs/etc/init.d/S60crond \
	rootfs/etc/profile.d/dhyve.sh \
	rootfs/etc/sudoers.d/docker \
	rootfs/etc/sysctl.conf \
	rootfs/etc/resolv.conf \
	rootfs/var/spool/cron/crontabs/root

BUILD_IMAGE     := dhyve-os-builder
BUILD_CONTAINER := dhyve-os-built

BUILT := `docker ps -aq -f name=$(BUILD_CONTAINER) -f exited=0`

all: $(TARGETS)

$(TARGETS): build | output
	docker cp $(BUILD_CONTAINER):/build/buildroot/output/images/$(@F) output/

build: $(SOURCES) | ccache dl
	$(eval SRC_UPDATED=$$(shell stat -f "%m" $^ | sort -gr | head -n1))
	$(eval STR_CREATED=$$(shell docker inspect -f '{{.Created}}' $(BUILD_IMAGE) 2>/dev/null))
	$(eval IMG_CREATED=$$(shell date -j -u -f "%FT%T" "$$(STR_CREATED)" +"%s" 2>/dev/null \
		|| echo 0))
	@if [ "$(SRC_UPDATED)" -gt "$(IMG_CREATED)" ]; then \
		set -e; \
		docker build --no-cache -t $(BUILD_IMAGE) .; \
		(docker rm -f $(BUILD_CONTAINER) || true); \
	fi
	@if [ "$(BUILT)" == "" ]; then \
		set -e; \
		(docker rm -f $(BUILD_CONTAINER) || true); \
		docker run -v ${PWD}/ccache:/build/buildroot/ccache \
			-v ${PWD}/dl:/build/buildroot/dl --name $(BUILD_CONTAINER) $(BUILD_IMAGE); \
	fi

output ccache dl:
	mkdir -p $@

clean:
	$(RM) -r output
	-docker rm -f $(BUILD_CONTAINER)

distclean: clean
	$(RM) -r ccache dl
	-docker rmi $(BUILD_IMAGE)

.PHONY: all build clean distclean
