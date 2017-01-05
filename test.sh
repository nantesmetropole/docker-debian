#!/bin/sh

set -e

# =================================================================
# Helpers
# =================================================================
check_from_docker() {
    cat /proc/1/cgroup | cut -d: -f3 | grep -q ^/docker
}

assert_equal() {
    if [ "$1" != "$2" ]; then
        echo "  $3:"
        echo "    Actual: $1"
        echo "    Expected: $2"
        return 1
    fi
}

# =================================================================
# Tests
# =================================================================
test_only_root() {
    local not_root="$(find / -xdev -not -user root -not -path "$PWD" -not -path /var/cache/apt/archives/partial -print -quit)"
    assert_equal "$not_root" '' 'first file not owned by root'
}

test_path_exclude() {
    local path_remaining="$(find /usr/share/doc/ -xdev -not -name copyright -type f -print -quit)"
    assert_equal "$path_remaining" '' 'first files excluded from dpkg but found'
}

test_tz() {
    assert_equal "$(date +%Z)" CET TZ
}

test_lang() {
    local output="$(ls nonexisting 2>&1 | grep -c 'Aucun fichier ou dossier de ce type')"
    assert_equal "$output" '1' 'french'
}

test_packages() {
    local pkg
    local should_not
    for pkg in $(dpkg-query -Wf '${Package}\n'); do
        case $pkg in
            acl|debconf-i18n)
                should_not="$should_not $pkg"
            ;;
            dmsetup|libdevmapper*|libcryptsetup*)
                should_not="$should_not $pkg"
            ;;
            init|systemd|systemd-sysv|sysvinit-core|upstart|udev)
                should_not="$should_not $pkg"
            ;;
            e2fs*)
                should_not="$should_not $pkg"
            ;;
        esac
    done
    assert_equal "$should_not" '' 'Packages should not be installed'
}
# =================================================================
# main
# =================================================================
check_from_docker || {
    echo "ERROR: Tests should be run from a docker container"
    exit 1
}
failures=0
for t in only_root path_exclude tz lang packages; do
    echo "========================================"
    echo "Test: $t: "
    if "test_$t"; then
        echo " OK"
    else
        echo " FAILED!"
        failures=$((failures+1))
    fi
done
if [ "$failures" != 0 ]; then
    exit 1
fi
