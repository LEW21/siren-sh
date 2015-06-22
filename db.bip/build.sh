#!/bin/sh
. `dirname $0`/siren

FROM gollum

ID bip `dbus-uuidgen`

cp -R ssh/* $root/gollum/.ssh/
cp -R ssh.private/* $root/gollum/.ssh/
cp -R app.overrides/* $root/gollum/
cp -R app.overrides.private/* $root/gollum/
RUN chown -R gollum:gollum /gollum
