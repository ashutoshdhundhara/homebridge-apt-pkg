ARG BASE_IMAGE
FROM ${BASE_IMAGE:-library/debian:bullseye}

ARG QEMU_ARCH
ENV QEMU_ARCH=${QEMU_ARCH:-x86_64} S6_KEEP_ENV=1

COPY build/qemu/qemu-${QEMU_ARCH}-static /usr/bin/

RUN apt-get update && \
  apt-get install -y build-essential debhelper debhelper dh-make devscripts jq

WORKDIR /repo

CMD [ "/repo/build.sh" ]
