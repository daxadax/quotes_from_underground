require 'dotenv'
Dotenv.load

require 'rubygems'
require 'bundler/setup'
require 'sass/plugin/rack'

stylesheet_dir = File.expand_path('public/stylesheets', __dir__)
Sass::Plugin.options.update(
  css_location: stylesheet_dir,
  template_location: File.join(stylesheet_dir, 'sass'),
  style: :compressed,
  always_update: ENV.fetch('RACK_ENV', 'development') != 'production'
)
use Sass::Plugin::Rack
Bundler.require

# lib
require './lib/init'

# app
Dir.glob('./helpers/*.rb') { |f| require f }
require 'redcarpet'
require './server.rb'

enable :sessions
set :session_secret, ENV['SESSION_KEY'] || 'a not so secret key'

run Server
