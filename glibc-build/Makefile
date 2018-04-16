all: glibc-build

glibc-build: build.sh
	/bin/bash build.sh # requires sudo

deploy:
	@echo "Deploy with Travis CI"
	touch GLIBC_BUILD_DEPLOY.out
