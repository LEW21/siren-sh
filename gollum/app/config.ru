__DIR__ = File.expand_path(File.dirname(__FILE__))
$: << __DIR__
require 'rubygems'
require 'bundler/setup'
require 'yaml'
require 'gollum'
Gollum::GIT_ADAPTER = "rugged"
require 'gollum/app'
require 'gollumauth'

users = YAML.load_file(File.expand_path('users.yml', __DIR__))
use GollumAuth::Middleware
GollumAuth::USERS = users.map {|u| GollumAuth::User.new(*u.values_at(*GollumAuth::User.members.map{|s| s.to_s})) }

Precious::App.set(:gollum_path, "/gollum/wiki")
Precious::App.set(:wiki_options, {allow_editing: true, universal_toc: true, show_all: true, allow_uploads: true, per_page_uploads: true, index_page: "BIP", h1_title: true})

Gollum::Hook.register(:post_commit, :hook_id) do |committer, sha1|
  path = Precious::App.settings.gollum_path
  puts(`git -C #{path} stash`)
  puts(`git -C #{path} fetch origin`)
  puts(`git -C #{path} rebase -Xtheirs origin/master`)
  puts(`git -C #{path} push`)
  puts(`git -C #{path} stash pop`)
end

run Precious::App
