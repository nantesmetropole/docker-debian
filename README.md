Nantes Métropole's docker-debian
================================

[![Build Status](https://travis-ci.org/nantesmetropole/docker-debian.svg?branch=master)](https://travis-ci.org/nantesmetropole/docker-debian)

This is our work-in-progress home-made tooling to create docker images.

Specifics:
- trimmed (see [here](templates/etc/dpkg/dpkg.cfg.d/01_save-space))
- LANG=fr_FR.UTF-8
- TZ=Europe/Paris
- Only 1 non-empty layer

License
-------

Apache-2.0, see [LICENSE](LICENSE) file.
