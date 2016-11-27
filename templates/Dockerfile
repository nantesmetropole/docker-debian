FROM scratch

LABEL vendor="Nantes Métropole"

ADD rootfs.tar.xz /
COPY resolv.conf /etc


# NB: We need to re-do dpkg.cfg's path-exlude as debootstrap doesn't apply it
RUN find /usr/share/doc/*    -mindepth 1 -not -name copyright -delete && \
    find /usr/share/locale/* -mindepth 1 -not -name "fr*" -not -name locale.alias -delete 2>/dev/null && \
    rm -r /usr/share/man/* \
          /usr/share/groff/* \
          /usr/share/info/* \
          /usr/share/lintian/* \
          /usr/share/linda/* \
          /usr/share/pyshared/twisted/test* \
          /usr/lib/python*/dist-packages/twisted/test* \
          /usr/share/pyshared/twisted/*/test* \
          /usr/lib/python*/dist-packages/twisted/*/test* &&
    \
    apt-get update && apt-get install -y \
    locales \
    vim && \
    \
    for locale in 'fr_FR.UTF-8 UTF-8'; do \
      sed -i -e "0,/^[# ]*$locale *$/ s/^[# ]*$locale *$/$locale/" /etc/locale.gen; \
    done && \
    locale-gen && \
    update-locale LANG=fr_FR.UTF-8 && \
    \
    ln -nsf /usr/share/zoneinfo/Europe/Paris /etc/localtime && \
    DEBIAN_FRONTEND=noninteractive dpkg-reconfigure tzdata && \
    \
    rm -rf /var/lib/apt/lists/*

ENV LANG fr_FR.UTF-8
CMD ["/bin/bash"]
