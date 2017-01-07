#!/bin/sh
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

set -e

echo ">>>> Removing files"
(
    set -x
    # NB: We need to re-do dpkg.cfg's path-exlude as debootstrap doesn't apply it
    find /usr/share/doc/* \
        -mindepth 1 \
        -not -name copyright \
        -delete
    find /usr/share/locale/* \
        -not -path "/usr/share/locale/fr*" \
        -not -path "/usr/share/locale/locale.alias" \
        -delete
    rm -rf \
        /usr/share/man/* \
        /usr/share/groff/* \
        /usr/share/info/* \
        /usr/share/lintian/* \
        /usr/share/linda/* \
        /usr/share/pyshared/twisted/test* \
        /usr/lib/python*/dist-packages/twisted/test* \
        /usr/share/pyshared/twisted/*/test* \
        /usr/lib/python*/dist-packages/twisted/*/test* \
        \
        /lib/udev/hwdb.bin
    mkdir \
        /usr/share/man/man1 \
        /usr/share/man/man2 \
        /usr/share/man/man3 \
        /usr/share/man/man4 \
        /usr/share/man/man5 \
        /usr/share/man/man6 \
        /usr/share/man/man7 \
        /usr/share/man/man8
)

echo ">>>> Removing init system"
(
    set -x
    if grep -xFq 'VERSION="7 (wheezy)"' /etc/os-release; then # wheezy
        dpkg --force-remove-essential -P \
            debconf-i18n \
            e2fsprogs e2fslibs
    elif grep -xFq 'VERSION="8 (jessie)"' /etc/os-release; then # jessie
        dpkg --force-remove-essential -P \
            acl debconf-i18n \
            dmsetup libdevmapper1.02.1 libcryptsetup4 \
            init systemd systemd-sysv sysvinit-core upstart udev \
            e2fsprogs e2fslibs
    else # >= stretch
        dpkg --force-remove-essential -P \
            e2fsprogs e2fslibs
    fi
)

echo ">>>> Configuring locales"
(
    set -x
    for locale in 'fr_FR.UTF-8 UTF-8'; do
        sed -i -e "0,/^[# ]*$locale *$/ s/^[# ]*$locale *$/$locale/" /etc/locale.gen
    done
    locale-gen
    update-locale LANG=fr_FR.UTF-8
)

echo ">>>> Configuring timezone"
(
    set -x
    ln -nsf /usr/share/zoneinfo/Europe/Paris /etc/localtime
    DEBIAN_FRONTEND=noninteractive dpkg-reconfigure tzdata
    rm -rf /var/lib/apt/lists/*
)
