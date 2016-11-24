FROM scratch

LABEL vendor="Nantes Métropole"

ADD rootfs.tar.xz /
COPY resolv.conf /etc

RUN apt-get update && apt-get install -y \
    locales \
    vim \
    && \
    echo 'locales locales/default_environment_locale string fr_FR.UTF-8' | debconf-set-selections \
    && \
    ln -nsf /usr/share/zoneinfo/Europe/Paris /etc/localtime && \
    DEBIAN_FRONTEND=noninteractive dpkg-reconfigure tzdata \
    && \
    rm -rf /var/lib/apt/lists/*

CMD ["/bin/bash"]
