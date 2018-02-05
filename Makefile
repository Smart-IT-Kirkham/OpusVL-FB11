.PHONY: clean dist docker

clean:
	dzil clean
dist:
	dzil build
docker: dist
	docker build \
		--build-arg version=`dzil distversion` \
		--build-arg gitrev="`set -x ; git rev-parse HEAD ; git status ; git diff`" \
		-t quay.io/opusvl/fb11:latest .
