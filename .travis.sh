#!/bin/bash

# Determine which directories (docker-images) need to be built and released

COMMIT=`git log -1 --pretty=format:"%H"`
UPDATED_FILES=`git diff-tree --no-commit-id --name-only -r $COMMIT`
UPDATED_DIRS=`echo $UPDATED_FILES | cut -d/ -f1 | uniq`

for dir in $UPDATED_DIRS; do
	cd $dir
	make
	make deploy
	cd ..
done
