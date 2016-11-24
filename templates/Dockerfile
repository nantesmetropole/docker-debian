FROM scratch

LABEL vendor="Nantes Métropole"

ADD rootfs.tar.xz /
COPY resolv.conf /etc

RUN apt-get update && apt-get install -y \
    locales \
    vim \
    && \
    for locale in 'fr_FR.UTF-8 UTF-8'; do \
      sed -i -e "0,/^[# ]*$locale *$/ s/^[# ]*$locale *$/$locale/" /etc/locale.gen; \
    done; \
    locale-gen; \
    rm -rf /var/lib/apt/lists/*

CMD ["/bin/bash"]
