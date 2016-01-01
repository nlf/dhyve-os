build: | output
	docker build -t dhyve-os-build .
	docker volume create --name dhyve-dl
	docker volume create --name dhyve-ccache
	docker run -it --name dhyve-os-builder \
		-v ${PWD}/config:/tmp/config \
		-v dhyve-dl:/tmp/buildroot/dl \
		-v dhyve-ccache:/tmp/buildroot/ccache \
		dhyve-os-build make --quiet
	docker cp dhyve-os-builder:/tmp/buildroot/output/images/bzImage output/
	docker cp dhyve-os-builder:/tmp/buildroot/output/images/rootfs.cpio.xz output/
	docker rm dhyve-os-builder

config:
	docker build -t dhyve-os-build .
	docker run -it --name dhyve-os-builder \
		-v ${PWD}/config:/tmp/config \
		dhyve-os-build /bin/bash -c 'cd /tmp/buildroot; make nconfig && cp /tmp/buildroot/.config /tmp/config/buildroot || true'
	docker rm dhyve-os-builder

linux-config:
	docker build -t dhyve-os-build .
	docker volume create --name dhyve-dl
	docker volume create --name dhyve-ccache
	docker run -it --name dhyve-os-builder \
		-v ${PWD}/config:/tmp/config \
		-v dhyve-dl:/tmp/buildroot/dl \
		-v dhyve-ccache:/tmp/buildroot/ccache \
		dhyve-os-build /bin/bash -c 'cd /tmp/buildroot; make linux-menuconfig'
	docker rm dhyve-os-builder

clean:
	rm -rf output
	-docker rm dhyve-os-builder

dist-clean: clean
	-docker volume rm dhyve-dl
	-docker volume rm dhyve-ccache
	-docker rmi dhyve-os-build

output:
	mkdir -p $@

.PHONY: build config linux-config clean dist-clean
