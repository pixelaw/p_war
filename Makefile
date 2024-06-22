PROFILE ?= dev

build:
	sozo --profile $(PROFILE) build;

test:
	sozo --profile $(PROFILE) test;

deploy_new: reset deploy
	scarb --profile $(PROFILE) run initialize;
	scarb --profile $(PROFILE) run upload_manifest;
	@echo "PixeLAW should be back at http://localhost:$(SERVER_PORT) again."

deploy_local:
	/pixelaw/tools/local_deploy.sh


deploy: build
	sozo --profile $(PROFILE) migrate plan;

dev:
	sozo --profile $(PROFILE) dev --name pixelaw;

