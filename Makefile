.PHONY: clean dist docker

version = $(shell dzil distversion)
LIBFILES   = $(shell git ls-files lib)
BINFILES   = $(shell git ls-files bin script)
TFILES     = $(shell git ls-files t)
OTHERFILES = cpanfile

clean:
	dzil clean
OpusVL-FB11-%.tar.gz: $(LIBFILES) $(BINFILES) $(TFILES) $(OTHERFILES)
	dzil build
dist: OpusVL-FB11-$(version).tar.gz
docker: dist
	docker build \
		--build-arg version=`dzil distversion` \
		--build-arg gitrev="`set -x ; git rev-parse HEAD ; git status ; git diff`" \
		-t quay.io/opusvl/fb11:latest .
