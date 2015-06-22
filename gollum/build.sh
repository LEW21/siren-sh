#!/bin/sh
. `dirname $0`/siren

FROM arch

ID gollum `dbus-uuidgen`

RUN pacman -S --noconfirm ruby git base-devel icu cmake openssh
RUN gem install --no-user-install bundler

cp gollum.sysusers $root/usr/lib/sysusers.d/gollum.conf
RUN systemd-sysusers

mkdir -p $root/gollum $root/gollum/.ssh
cp Gemfile $root/gollum
RUN chown -R gollum:gollum /gollum

RUN -u gollum bash -c "cd; exec bundle install --path .gem"

cp -R ssh.config $root/gollum/.ssh/config
cp -R app/* $root/gollum/
RUN chown -R gollum:gollum /gollum

rmdir $root/srv/*
chmod o+w $root/srv

RUN -u gollum git config --global push.default simple

ENABLE gollum.socket
ENABLE gollum.service
