all: glibc-build

glibc-build: build.sh
	wget -nv http://willmarkley.com/glibc-2.27-wml.tar.gz 
	#/bin/bash build.sh # requires sudo 

deploy:
	@echo "Deploy with Travis CI"
	touch GLIBC_BUILD_DEPLOY.out
