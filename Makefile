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
