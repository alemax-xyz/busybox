FROM library/debian:stable-slim AS build

ENV LANG=C.UTF-8

ADD https://github.com/alemax-xyz/apt-sandbox.git#main /usr/local/bin/

RUN mkdir -p \
        /build \
        /rootfs

COPY build/ build/

RUN apt-sandbox --install --verstamp \
        --apt-config APT::Install-Recommends=false \
        --repository /build \
        --keyring /build \
        --required /build/packages.required

WORKDIR /rootfs

COPY rootfs/ .

RUN mkdir -p bin dev home root sbin tmp run var/log \
 && cp usr/share/libc-bin/nsswitch.conf etc/ \
 && chmod 1777 tmp \
 && ln -s /run var/run \
 && ln -s /usr/lib lib \
 && ln -s /usr/lib64 lib64 \
 && ln -s /$(find usr/lib -type f -name 'ld*.so*' -executable | head -1) usr/lib/ld-linux.so \
 && chmod u+s,g+s usr/bin/busybox \
 && ./usr/bin/busybox --list-full | xargs -I % ln -s /usr/bin/busybox % \
 && chmod 0640 etc/shadow \
 && chmod 0644 \
        etc/group \
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
        usr/lib/*/gconv/gconv-modules \
        usr/lib/*/gconv/gconv-modules.d/*.conf \
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

CMD ["sh", "-l"]
