## @license AGPLv3 <https://www.gnu.org/licenses/agpl-3.0.html>
## @author Copyright (C) 2016 Mathieu Parent <math.parent@gmail.com>
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


MKIMAGE = /usr/share/docker.io/contrib/mkimage.sh

default:
	@echo;\
	echo ERROR: no target specified, try make image;\
	echo;\
	exit 1

builddir:
	@if [ -e build ]; then\
	  echo 'WARNING: build directory already exists (run make clean)';\
	fi
	mkdir -p build

# Create rootfs.tar.xz
image-rootfs: builddir
	mkdir build/rootfs
	cp -a templates/etc build/rootfs/
	sudo chown -Rc root:root build/rootfs/etc
	sudo $(MKIMAGE) --dir build --compression xz \
	  debootstrap "--variant=$(DEBOOTSTRAP_VARIANT)" \
	  --components=main \
	  --include=inetutils-ping,iproute2 \
	  --force-check-gpg \
	  "$(DIST)" \
	  "$(DEBOOTSTRAP_MIRROR)"

# Create Dockerfile and required files
image-dockerfile: builddir
	@diff -u build/Dockerfile templates/Dockerfile ||:
	rm -f build/Dockerfile
	cp -a templates/Dockerfile build/Dockerfile
	# resolv.conf
	grep ^nameserver /etc/resolv.conf | tee build/resolv.conf

image: image-rootfs image-dockerfile
	docker build -t "$(DOCKER_TAG)" build

test-local:
	./test.sh

test:
	docker run -t -v "$(CURDIR):$(CURDIR)" -w "$(CURDIR)" "$(DOCKER_TAG)" ./test.sh

clean:
	rm -rf build
