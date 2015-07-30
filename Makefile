all: output/rootfs.cpio.xz output/bzImage

output/rootfs.cpio.xz output/bzImage: | output
	@docker inspect dhyve-os-built >/dev/null 2>&1; if [ $$? -ne 0 ]; then echo "Built container missing, run 'make build' first"; exit 1; fi
	@docker cp dhyve-os-built:/build/buildroot/output/images/$(@F) output/

build: config rootfs | ccache
	docker build -t dhyve-os-build .
	-docker rm dhyve-os-built
	docker run -v ${PWD}/ccache:/build/buildroot/ccache --name=dhyve-os-built dhyve-os-build

output ccache:
	mkdir -p $@

clean:
	rm -rf output
	-docker rm dhyve-os-built

distclean: clean
	rm -rf ccache
	-docker rmi dhyve-os-build

.phony: build clean distclean
