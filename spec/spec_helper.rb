require 'minitest/autorun'
require 'minitest/spec'

require 'bcrypt'
require 'pry'

$LOAD_PATH.unshift('lib', 'spec')

ENV['test'] = '1'
BCrypt::Engine::DEFAULT_COST = 1

# require './lib/init' < this breaks things due to service factory i guess?
require './lib/service_registration'
require './lib/service_factory'

require './lib/users'
require './lib/quotes'

# require all support files
Dir.glob('./spec/support/*.rb')  { |f| require f }

class  Minitest::Spec
  include Support::AssertionHelpers
  include Support::FactoryHelpers
end
