# DhyveOS

DhyveOS is a lightweight Linux distribution made specifically to run [Docker](https://www.docker.com/) containers within the [xhyve](https://github.com/mist64/xhyve) hypervisor on OS X. It runs completely from RAM, is a small ~10MB download and boots in ~5s (YMMV).

## Features

* NFS share automounts to /Users
* Docker runs on port 2375 without TLS
* Designed for use with [dhyve](https://github.com/nlf/dhyve)

## Caveat Emptor

DhyveOS is currently designed and tuned for development.  Using it for any kind of production workloads at this time is highly discouraged.
