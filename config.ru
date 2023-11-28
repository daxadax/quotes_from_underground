require 'dotenv'
Dotenv.load

require 'rubygems'
require 'bundler/setup'
require 'sass/plugin/rack'

Sass::Plugin.options[:style] = :compressed
use Sass::Plugin::Rack
Bundler.require

# lib
require './lib/init'

# app
Dir.glob('./app/helpers/*.rb') { |f| require f }
require 'redcarpet'
require './app/server.rb'

enable :sessions
set :session_secret, ENV['SESSION_KEY'] || 'a not so secret key'

run Server
