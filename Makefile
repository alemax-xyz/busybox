TAG ?= clover/busybox

latest:
	docker buildx build --platform linux/amd64,linux/386,linux/arm/v7,linux/arm64/v8,linux/ppc64le,linux/s390x,linux/riscv64 --tag ${TAG}:$@ --push .

.PHONY: latest
