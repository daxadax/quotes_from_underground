require 'sequel'
DATABASE_CONNECTION = Sequel.connect(ENV['DATABASE_URL'])

require './lib/boot'
