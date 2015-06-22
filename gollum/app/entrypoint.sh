#!/bin/bash
set -e

cd /gollum
export PATH="$PATH:~/.gem/ruby/2.2.0/bin"

echo "Installing static file overrides..."

GOLLUM_STATIC_FILES="`bundle show gollum`/lib/gollum/public/gollum"

custom_files=$(shopt -s nullglob;echo /gollum/srv/*)
if [ ${#custom_files} -gt 0 ]
then
	cp -R /gollum/srv/* $GOLLUM_STATIC_FILES
fi

echo "Installing template overrides..."

GOLLUM_TEMPLATES="`bundle show gollum`/lib/gollum/templates"

custom_templates=$(shopt -s nullglob;echo /gollum/templates/*)
if [ ${#custom_templates} -gt 0 ]
then
	cp -R /gollum/templates/* $GOLLUM_TEMPLATES
fi

echo "Copying static files to /srv..."
cp -R $GOLLUM_STATIC_FILES/* /srv

echo "Syncing git repository..."

git config --global user.name "$GIT_USER_NAME"
git config --global user.email "$GIT_USER_EMAIL"

if [ ! -d /gollum/wiki ]
then
	cd /gollum
	git clone $GIT_REPO wiki
fi

echo "cloned"

cd /gollum/wiki
git reset --hard
git fetch origin
git rebase -Xtheirs origin/master
git push
cd /gollum

exec "$@"
