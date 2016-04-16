# DhyveOS

DhyveOS is a lightweight Linux distribution made specifically to run [Docker](https://www.docker.com/) containers within the [xhyve](https://github.com/mist64/xhyve) hypervisor on OS X. It runs completely from RAM, is a small ~14MB download and boots in ~5s (YMMV).

## Features

* Uses 9P over virtio to mount your user's home directory so volume mappings work.
* Docker runs on port 2375 without TLS
* Designed for use with [dlite](https://github.com/nlf/dlite)
* Default root password: dhyve
* Default docker user password: docker
* Uses btrfs for the docker filesystem

## Building

Building DhyveOS requires docker. To build it, just run `make`. Binaries will be located in the `output` directory.

Downloads and ccache output are stored in named docker volumes to speed up subsequent builds.

Running `make clean` will remove the output directory as well as the intermediate container (if it exists).

`make dist-clean` will additionally remove the base image, as well as the named volumes.

If you'd like to tweak the buildroot configuration, run `make config`. When you save changes they will be copied to the `config` directory appropriately.

To make changes to the kernel configuration, run `make linux-config`. When saving, make sure to specify the filename `/tmp/config/kernel` or your changes will be lost.

## Caveat Emptor

DhyveOS is currently designed and tuned for development.  Using it for any kind of production workloads at this time is highly discouraged.
