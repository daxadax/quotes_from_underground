require 'minitest/autorun'
require 'minitest/spec'

require 'bcrypt'

ENV['test'] = '1'
BCrypt::Engine::DEFAULT_COST = 1
