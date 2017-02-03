## Copyright 2016-2017 Mathieu Parent <math.parent@gmail.com>
##
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.

DIST                        ?= jessie
DEBOOTSTRAP_VARIANT         ?= minbase
DEBOOTSTRAP_FORCE_GPG_CHECK ?= yes
DEBOOTSTRAP_MIRROR          ?= http://deb.debian.org/debian
DOCKER_USER                 ?= nantesmetropole
DOCKER_TAG                  ?= $(DOCKER_USER)/debian:$(DIST)


ifneq ("$(wildcard /usr/share/docker.io/contrib/mkimage)","")
MKIMAGE_SCRIPTDIR = /usr/share/docker.io/contrib/mkimage
else
MKIMAGE_SCRIPTDIR = /usr/share/docker-engine/contrib/mkimage
endif

ifeq (no, $(DEBOOTSTRAP_FORCE_GPG_CHECK))
DEBOOTSTRAP_FORCE_GPG_CHECK_OPT=
else
DEBOOTSTRAP_FORCE_GPG_CHECK_OPT=--force-check-gpg
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
	sudo chown -Rc root:root build/rootfs/etc
	sudo $(MKIMAGE_SCRIPTDIR)/debootstrap \
	  ./build/rootfs \
	  "--variant=$(DEBOOTSTRAP_VARIANT)" \
	  --components=main \
	  --include=locales \
	  $(DEBOOTSTRAP_FORCE_GPG_CHECK_OPT) \
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

push:
	docker push "$(DOCKER_TAG)"

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
