FROM library/debian:stable-slim AS build

ENV LANG=C.UTF-8

RUN export DEBIAN_FRONTEND=noninteractive \
 && apt-get update

RUN mkdir -p /build /rootfs
WORKDIR /build
RUN apt-get download \
        libgcc-s1 \
        libcrypt1 \
        libc6 \
        libc-bin \
        netbase \
        busybox
RUN find . -name '*.deb' -exec dpkg-deb -x {} /rootfs \;

WORKDIR /rootfs
COPY etc/ etc/
COPY usr/local/bin/ usr/local/bin/
RUN mkdir -p dev home root tmp run var/log \
 && cp usr/share/libc-bin/nsswitch.conf etc/ \
 && chmod 1777 tmp \
 && ln -s /run var/run \
 && ln -s /usr/lib lib \
 && ln -s /usr/lib64 lib64 \
 && ln -s /$(find usr/lib -type f -name 'ld*.so*' -executable | head -1) usr/lib/ld-linux.so \
 && chmod u+s,g+s usr/bin/busybox \
 && ./usr/bin/busybox --list-full | xargs dirname | sort | uniq | xargs mkdir -p \
 && ./usr/bin/busybox --list-full | xargs -I % ln -s /usr/bin/busybox % \
 && chmod 0640 etc/shadow \
 && chmod 0666 \
        etc/group \
        etc/login.defs \
        etc/nsswitch.conf \
        etc/passwd \
        etc/networks \
 && find \
        etc/*.conf \
        etc/ld.so.conf.d/*.conf \
        etc/bindresvport.blacklist \
        etc/ethertypes \
        etc/default/nss \
        etc/protocols \
        etc/rpc \
        etc/services \
    | xargs -I % \
        sed -i -r \
            -e 's,[[:space:]]*[#]+.*$,,g' \
            -e '/^$/d' \
            -e 's,[[:space:]]+, ,g' \
            % \
 && rm -rf \
        linuxrc \
        etc/default \
        usr/bin/ldd \
        usr/bin/tzselect \
        usr/share

WORKDIR /


FROM scratch

ENV LANG=C.UTF-8

COPY --from=build /rootfs /

CMD ["sh"]
