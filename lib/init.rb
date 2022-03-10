print "##############################\n\n"
print "Using DATABASE:  #{ENV['DATABASE_URL']}\n\n"
print "##############################\n"

require 'sequel'
DATABASE_CONNECTION = Sequel.connect(ENV['DATABASE_URL'])

require './lib/service_registration'
require './lib/service_factory'

require './lib/users'
require './lib/quotes'

ServiceFactory.register :quotes_backend do
  Persistence::Gateways::QuotesGatewayBackend.new
end

ServiceFactory.register :publications_backend do
  Persistence::Gateways::PublicationsGatewayBackend.new
end

ServiceFactory.register :users_backend do
  Persistence::Gateways::UsersGatewayBackend.new
end
