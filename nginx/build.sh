#!/bin/sh
. `dirname $0`/siren

FROM arch

ID nginx $base_version

RUN pacman -S --noconfirm nginx
rm -Rf $root/etc/nginx
cp -R etc/nginx $root/etc/nginx

ENABLE nginx
CMD /usr/bin/nginx -g "daemon off; error_log stderr info;"
