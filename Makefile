all: output/rootfs.cpio.xz output/bzImage

output/rootfs.cpio.xz output/bzImage: | output
	@docker inspect dhyve-os-built >/dev/null 2>&1 || ${MAKE} build
	docker cp dhyve-os-built:/build/buildroot/output/images/$(@F) output/

build: | ccache dl
	docker build --no-cache -t dhyve-os-build .
	-docker rm dhyve-os-built
	docker run -v ${PWD}/ccache:/build/buildroot/ccache -v ${PWD}/dl:/build/buildroot/dl --name=dhyve-os-built dhyve-os-build

output ccache dl:
	mkdir -p $@

clean:
	rm -rf output
	-docker rm dhyve-os-built

distclean: clean
	rm -rf ccache dl
	-docker rmi dhyve-os-build

.phony: build clean distclean
