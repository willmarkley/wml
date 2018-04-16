all: glibc-build

glibc-build: build.sh
	# requires sudo
	/bin/bash build.sh

deploy:
	@echo "Deploy with Travis CI"
	touch GLIBC_BUILD_DEPLOY.out
