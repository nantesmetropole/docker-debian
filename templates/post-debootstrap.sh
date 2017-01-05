#!/bin/sh
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
