#!/bin/sh
. `dirname $0`/siren

#ID arch `date +%Y.%m.%d`
ID arch 2015.06.21

mkdir -m 0755 -p $root/var/{cache/pacman/pkg,lib/pacman,log} $root/{dev,run,etc}
mkdir -m 1777 -p $root/tmp
mkdir -m 0555 -p $root/{sys,proc}
pacman -Sy --noconfirm -r $root bash coreutils curl filesystem findutils gcc-libs glibc gzip pacman shadow tar xz sed grep systemd

SET /etc/pacman.d/mirrorlist "Server=http://seblu.net/a/arm/${version//.//}/\$repo/os/\$arch"
SET /etc/locale.gen "en_US.UTF-8 UTF-8"

RUN pacman-key --init
RUN pacman-key --populate
RUN pacman -Syu --noconfirm
RUN locale-gen

ENABLE systemd-networkd

# Not necessary, makes container smaller.
rm $root/etc/mtab
ln -s ../proc/self/mounts $root/etc/mtab
ln -s ../usr/lib/os-release $root/etc/os-release
