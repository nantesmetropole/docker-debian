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


MKIMAGE = /usr/share/docker.io/contrib/mkimage.sh

default:
	echo;\
	echo ERROR: no target specified, try make image;\
	echo;\
	exit 1

builddir:
	if [ -e build ]; then\
	  echo;\
	  echo ERROR: build directory already exists, run make clean;\
	  echo;\
	  exit 1;\
	fi
	mkdir build

image: builddir
	sudo $(MKIMAGE) --dir build --compression xz \
	  debootstrap "--variant=$(DEBOOTSTRAP_VARIANT)" \
	  --components=main \
	  --include=inetutils-ping,iproute2 \
	  --force-check-gpg \
	  "$(DIST)" \
	  "$(DEBOOTSTRAP_MIRROR)"

clean:
	rm -rf build
