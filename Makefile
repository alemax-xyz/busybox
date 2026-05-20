TAG ?= clover/busybox
PLATFORM ?= linux/amd64,linux/386,linux/arm/v7,linux/arm64/v8,linux/ppc64le,linux/s390x,linux/riscv64

latest:
	docker buildx build --progress plain --platform ${PLATFORM} --tag ${TAG}:$@ --push .

.PHONY: latest
