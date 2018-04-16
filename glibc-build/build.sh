#!/bin/bash

GLIBC=glibc-2.27
GLIBC_TAR=$GLIBC.tar.gz
GLIBC_URL=https://ftp.gnu.org/gnu/libc/$GLIBC_TAR

GLIBC_PATCH=glibc-2.27-fhs-1.patch
GLIBC_PATCH_URL=http://www.linuxfromscratch.org/patches/lfs/development/$GLIBC_PATCH

LINUX=linux-4.16.1
LINUX_TAR=$LINUX.tar.xz
LINUX_URL=https://cdn.kernel.org/pub/linux/kernel/v4.x/$LINUX_TAR

TZDATA=tzdata2018d.tar.gz
TZDATA_URL=https://data.iana.org/time-zones/releases/$TZDATA

TOOLCHAIN=toolchain-lfs.8.0.tar.gz
TOOLCHAIN_URL=https://github.com/willmarkley/wml/releases/download/v0.0/$TOOLCHAIN

ROOT_DIR=/mnt/wml

set -e

## Extract toolchain to a new directory (preferably on a mounted partition)
mkdir -pv $ROOT_DIR
wget -nv $TOOLCHAIN_URL
tar -xzf $TOOLCHAIN -C $ROOT_DIR

## Download sources to new ROOT directory
mkdir -pv $ROOT_DIR/sources
wget -nv -P $ROOT_DIR/sources $GLIBC_URL
wget -nv -P $ROOT_DIR/sources $GLIBC_PATCH_URL
wget -nv -P $ROOT_DIR/sources $LINUX_URL
wget -nv -P $ROOT_DIR/sources $TZDATA_URL

## Prepare Virtual Kernel File Systems
mkdir -pv $ROOT_DIR/{dev,proc,sys,run}
mknod -m 600 $ROOT_DIR/dev/console c 5 1
mknod -m 666 $ROOT_DIR/dev/null c 1 3
mount -v --bind /dev $ROOT_DIR/dev
mount -vt devpts devpts $ROOT_DIR/dev/pts -o gid=5,mode=620
mount -vt proc proc $ROOT_DIR/proc
mount -vt sysfs sysfs $ROOT_DIR/sys
mount -vt tmpfs tmpfs $ROOT_DIR/run
if [ -h $ROOT_DIR/dev/shm ]; then
  mkdir -pv $ROOT_DIR/$(readlink $ROOT_DIR/dev/shm)
fi

## Chroot
cp -v chroot.sh $ROOT_DIR
set +e
chroot $ROOT_DIR /tools/bin/env -i \
    HOME=/root                  \
    GLIBC=$GLIBC                \
    GLIBC_TAR=$GLIBC_TAR        \
    GLIBC_PATCH=$GLIBC_PATCH    \
    LINUX=$LINUX                \
    LINUX_TAR=$LINUX_TAR        \
    TZDATA=$TZDATA              \
    PS1='(lfs chroot) \u:\w\$ ' \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin:/tools/bin \
    /tools/bin/bash -c /chroot.sh

## Unmount Virtual Kernel File Systems
umount -v $ROOT_DIR/dev/pts
umount -v $ROOT_DIR/dev
umount -v $ROOT_DIR/run
umount -v $ROOT_DIR/proc
umount -v $ROOT_DIR/sys
rm -v $ROOT_DIR/dev/{console,null}

## Remove temporary symlinks and files
rm -v $ROOT_DIR/bin/{bash,cat,dd,echo,ln,pwd,rm,stty}
rm -v $ROOT_DIR/bin/{install,perl,m4}
rm -v $ROOT_DIR/lib/libgcc_s.so{,.1}
rm -v $ROOT_DIR/lib/libstdc++.{a,so{,.6}}
rm -v $ROOT_DIR/bin/sh
rm -v $ROOT_DIR/lib/gcc
rm -v $ROOT_DIR/chroot.sh

## Package completed build
CURR_DIR=`pwd`
cd $ROOT_DIR
tar --exclude='./tools' --exclude='./sources' -zcvf $CURR_DIR/$GLIBC-wml.tar.gz .
cd $CURR_DIR

## Cleanup build
rm -rf $ROOT_DIR
