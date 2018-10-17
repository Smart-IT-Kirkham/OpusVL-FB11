.PHONY: clean dist docker

version = $(shell dzil distversion)
LIBFILES   = $(shell git ls-files lib)
BINFILES   = $(shell git ls-files bin script)
TFILES     = $(shell git ls-files t)
OTHERFILES = cpanfile
ifeq ($(NOCACHE), 1)
	override NOCACHE = --no-cache
endif

clean:
	dzil clean
OpusVL-FB11-%.tar.gz: $(LIBFILES) $(BINFILES) $(TFILES) $(OTHERFILES)
	dzil build
dist: OpusVL-FB11-$(version).tar.gz
docker: dist
	docker build $(NOCACHE) \
		--build-arg version=`dzil distversion` \
		--build-arg gitrev="`set -x ; git rev-parse HEAD ; git status ; git diff`" \
		-t quay.io/opusvl/fb11:latest .
ifeq ($(PUSH), 1)
	docker push quay.io/opusvl/fb11:latest
endif
release:
	docker pull quay.io/opusvl/fb11:latest
	[ `docker run --rm -u root quay.io/opusvl/fb11:latest head -n1 /root/OpusVL-FB11-gitrev` = `git rev-parse HEAD` ]
	dzil release
	- docker tag quay.io/opusvl/fb11:latest quay.io/opusvl/fb11:$(version)
ifeq ($(PUSH), 1)
	- docker push quay.io/opusvl/fb11:$(version)
endif
