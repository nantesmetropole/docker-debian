Nantes Métropole's docker-debian
================================

[![Build Status](https://travis-ci.org/nantesmetropole/docker-debian.svg?branch=master)](https://travis-ci.org/nantesmetropole/docker-debian)

This is our work-in-progress home-made tooling to create docker images.

Specifics:
- trimmed (see [here](templates/etc/dpkg/dpkg.cfg.d/01_save-space) and [here](templates/post-debootstrap.sh))
- LANG=fr_FR.UTF-8
- TZ=Europe/Paris
- Only 1 non-empty layer

Usage
-----

Images are built weekly with travis, and [pushed to Docker Hub](https://hub.docker.com/r/nantesmetropole/debian/).

    docker pull nantesmetropole/debian:stretch # or jessie or wheezy

We also build them on our local gitlab instance.


Build your own
--------------

Configuration is made using environment variables:

```shell
# export DIST=jessie
# export DEBOOTSTRAP_VARIANT=minbase
# export DEBOOTSTRAP_MIRROR=http://deb.debian.org/debian
# export DOCKER_USER=nantesmetropole
# export DOCKER_TAG="$DOCKER_USER/debian:$DIST"
# export APT_HTTP_PROXY=auto

make image
make test
```

License
-------

Apache-2.0, see [LICENSE](LICENSE) file.
