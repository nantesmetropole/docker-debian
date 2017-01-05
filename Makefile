## @license AGPLv3 <https://www.gnu.org/licenses/agpl-3.0.html>
## @author Copyright (C) 2016-2017 Mathieu Parent <math.parent@gmail.com>
##
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU Affero General Public License as
## published by the Free Software Foundation, version 3 of the
## License.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU Affero General Public License for more details.
##
## You should have received a copy of the GNU Affero General Public License
## along with this program.  If not, see <https://www.gnu.org/licenses/>.

DIST                ?= jessie
DEBOOTSTRAP_VARIANT ?= minbase
DEBOOTSTRAP_MIRROR  ?= http://deb.debian.org/debian
DOCKER_USER         ?= nantesmetropole
DOCKER_TAG          ?= $(DOCKER_USER)/debian:$(DIST)


ifneq ("$(wildcard /usr/share/docker.io/contrib/mkimage)","")
MKIMAGE_SCRIPTDIR = /usr/share/docker.io/contrib/mkimage
else
MKIMAGE_SCRIPTDIR = /usr/share/docker-engine/contrib/mkimage
endif

default:
	@echo;\
	echo ERROR: no target specified, try make image;\
	echo;\
	exit 1

builddir:
	@if [ -e ./build ]; then\
	  echo 'WARNING: build directory already exists (run make clean)';\
	fi
	mkdir -p ./build

# Create rootfs.tar.xz
image-rootfs-tar: builddir
	rm -rf ./build/rootfs
	mkdir ./build/rootfs
	cp -a templates/etc build/rootfs/
	grep ^nameserver /etc/resolv.conf | tee build/rootfs/etc/resolv.conf
	sudo chown -Rc root:root build/rootfs/etc
	sudo $(MKIMAGE_SCRIPTDIR)/debootstrap \
	  ./build/rootfs \
	  "--variant=$(DEBOOTSTRAP_VARIANT)" \
	  --components=main \
	  --include=locales \
	  --force-check-gpg \
	  "$(DIST)" \
	  "$(DEBOOTSTRAP_MIRROR)"
	sudo cp ./templates/post-debootstrap.sh ./build/rootfs/post-debootstrap
	sudo chmod +x ./build/rootfs/post-debootstrap
	sudo chroot ./build/rootfs/ /post-debootstrap
	sudo rm ./build/rootfs/post-debootstrap
	# Docker mounts tmpfs at /dev and procfs at /proc so we can remove them
	sudo rm -rf "./build/rootfs/dev" "./build/rootfs/proc"
	sudo mkdir -p "./build/rootfs/dev" "./build/rootfs/proc"
	sudo tar --numeric-owner --create --auto-compress \
	  --file "./build/rootfs.tar.xz" \
	  --directory "./build/rootfs/" \
	  --transform='s,^./,,' \
	  .
	sudo rm -rf ./build/rootfs/

# Create Dockerfile and required files
image-dockerfile: builddir
	cp -a templates/Dockerfile ./build/Dockerfile

image: image-rootfs-tar image-dockerfile
	docker build -t "$(DOCKER_TAG)" ./build/

test-local:
	./test.sh

test:
	docker run -t \
	  -v "$(CURDIR):$(CURDIR)" \
	  -w "$(CURDIR)" \
	  --rm \
	  "$(DOCKER_TAG)" ./test.sh

clean:
	rm -rf ./build/
