.PHONY: clean dist docker

version = $(shell dzil distversion)
rcversion = $(shell dzil distversion --rc)
lastrcversion = $(shell dzil distversion --rc | perl -lpe 's/(\d+)$$/$$1-1/ge')
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
		-t registry.smart-ltd.co.uk/bca/fb11:latest .
rc: docker
	docker tag registry.smart-ltd.co.uk/bca/fb11:latest registry.smart-ltd.co.uk/bca/fb11:v$(rcversion)
	git tag v$(rcversion)
	docker push registry.smart-ltd.co.uk/bca/fb11:v$(rcversion)
	git push origin v$(rcversion)
release:
	- @echo "If this fails, make sure you pushed the last image you built"
	docker pull registry.smart-ltd.co.uk/bca/fb11:v$(lastrcversion)
	@[ `docker run --rm -u root registry.smart-ltd.co.uk/bca/fb11:v$(lastrcversion) head -n1 /root/OpusVL-FB11-gitrev` = `git rev-parse HEAD` ] \
		|| echo "Ensure your git repository is on the commit from which the latest image was built (or rebuild and retest)."
	dzil release
	- docker tag registry.smart-ltd.co.uk/bca/fb11:latest registry.smart-ltd.co.uk/bca/fb11:v$(version)
	- docker push registry.smart-ltd.co.uk/bca/fb11:v$(version)
