REPO = ghcr.io/pixelaw/vanilla
VERSION = $(shell cat VERSION)


docker_build:
	docker build -t $(REPO):$(VERSION) -t $(REPO):latest \
  	--network=host \
	--progress=plain .

