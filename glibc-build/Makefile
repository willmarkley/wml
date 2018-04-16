all: glibc-build

# requires sudo
glibc-build: build.sh
	wget http://willmarkley.com/glibc-2.27-wml.tar.gz 
	#/bin/bash build.sh

deploy:
	@echo "Deploy with Travis CI"
	touch GLIBC_BUILD_DEPLOY.out
