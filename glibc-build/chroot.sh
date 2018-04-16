## chroot.sh
##    executed in the chroot environment with the TOOLCHAIN


## PREPARE FOR INSTALLS ##

## Create Directories and Links (FHS)
mkdir -pv /{boot,etc/{opt,sysconfig},home,mnt,opt}
mkdir -pv /{media/{floppy,cdrom},srv,var}
install -dv -m 0750 /root
install -dv -m 1777 /tmp /var/tmp
mkdir -pv /usr/{,local/}{bin,include,lib,sbin,src}
mkdir -pv /usr/{,local/}share/{color,dict,doc,info,locale,man}
mkdir -v  /usr/{,local/}share/{misc,terminfo,zoneinfo}
mkdir -v  /usr/libexec
mkdir -pv /usr/lib/firmware
mkdir -pv /usr/{,local/}share/man/man{1..8}
ln -sv usr/bin /bin
ln -sv usr/lib /lib
ln -sv usr/sbin /sbin
ln -sv lib /lib64
mkdir -v /var/{log,mail,spool}
ln -sv /run /var/run
ln -sv /run/lock /var/lock
mkdir -pv /var/{opt,cache,lib/{color,misc,locate},local}

## Create temporary symlinks
ln -sv /tools/bin/{bash,cat,dd,echo,ln,pwd,rm,stty} /bin
ln -sv /tools/bin/{install,perl,m4} /usr/bin
ln -sv /tools/lib/libgcc_s.so{,.1} /usr/lib
ln -sv /tools/lib/libstdc++.{a,so{,.6}} /usr/lib
ln -sv bash /bin/sh
cp -v /tools/lib/ld-linux-x86-64.so.2 /lib64


## INSTALL LINUX KERNEL API HEADERS ##
echo "INSTALL LINUX KERNEL API HEADERS"
## Extract and change directory
cd /sources
tar -xf $LINUX_TAR
cd $LINUX

## Build and install headers
make mrproper
make --silent INSTALL_HDR_PATH=dest headers_install
find dest/include \( -name .install -o -name ..install.cmd \) -delete
cp -rv dest/include/* /usr/include


## INSTALL GLIBC ##
echo "INSTALL GLIBC"
## Extract and change directory
cd /sources
tar -xf $GLIBC_TAR
cd $GLIBC

## Apply patch to meet FHS
patch -Np1 -i ../$GLIBC_PATCH

## Add compatibility for build
ln -sfv /tools/lib/gcc /usr/lib
GCC_INCDIR=/usr/lib/gcc/x86_64-pc-linux-gnu/7.3.0/include
ln -sfv ld-linux-x86-64.so.2 /lib64/ld-lsb-x86-64.so.3
rm -f /usr/include/limits.h

## Create separate build directory
mkdir -v build
cd       build

## configure
CC="gcc -isystem $GCC_INCDIR -isystem /usr/include" \
../configure --prefix=/usr                          \
             --disable-werror                       \
             --enable-kernel=3.2                    \
             --enable-stack-protector=strong        \
             libc_cv_slibdir=/lib
unset GCC_INCDIR

## make
make --silent

## make install
sed '/test-installation/s@$(PERL)@echo not running@' -i ../Makefile
make --silent install

## nscd
cp -v ../nscd/nscd.conf /etc/nscd.conf
mkdir -pv /var/cache/nscd

# Locales
mkdir -pv /usr/lib/locale
localedef -i en_US -f ISO-8859-1 en_US
localedef -i en_US -f UTF-8 en_US.UTF-8

## Timezone
tar -xf ../../$TZDATA
ZONEINFO=/usr/share/zoneinfo
mkdir -pv $ZONEINFO/{posix,right}
for tz in etcetera southamerica northamerica europe africa antarctica  \
          asia australasia backward pacificnew systemv; do
    zic -L /dev/null   -d $ZONEINFO       -y "sh yearistype.sh" ${tz}
    zic -L /dev/null   -d $ZONEINFO/posix -y "sh yearistype.sh" ${tz}
    zic -L leapseconds -d $ZONEINFO/right -y "sh yearistype.sh" ${tz}
done
cp -v zone.tab zone1970.tab iso3166.tab $ZONEINFO
zic -d $ZONEINFO -p America/New_York
unset ZONEINFO
