#
# This is a multi-stage build.
# Actual build is at the very end.
#

FROM library/ubuntu:xenial AS build

ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8
RUN apt-get update && \
    apt-get install -y \
        python-software-properties \
        software-properties-common \
        apt-utils

RUN mkdir -p /build/image
WORKDIR /build
RUN apt-get download \
        busybox \
        libgcc1 \
        libc6
RUN for file in *.deb; do dpkg-deb -x ${file} image/; done

WORKDIR /build/image
RUN mkdir -p home etc dev root tmp run var/mail var/log && \
    chmod 1777 tmp && \
    ln -s /run var/run
COPY group localtime login.defs nsswitch.conf passwd shadow etc/
RUN chmod 0640 etc/shadow && \
    chmod 0666 etc/group etc/localtime etc/login.defs etc/nsswitch.conf etc/passwd && \
    ./bin/busybox --list-full | xargs dirname | sort | uniq | xargs mkdir -p && \
    ./bin/busybox --list-full | xargs -n1 ln -s /bin/busybox && \
    rm -rf usr/share


FROM scratch

WORKDIR /
COPY --from=build /build/image /

CMD ["sh"]
