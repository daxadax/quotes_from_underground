require 'support/fake_quotes_backend'
require 'support/fake_publications_backend'
require 'support/fake_users_backend'

class FakeGatewayAccess < MiniTest::Spec
  @@fake_for_pubs = Support::FakePublicationsBackend.new
  @@fake_for_quotes = Support::FakeQuotesBackend.new @@fake_for_pubs
  @@fake_for_users = Support::FakeUsersBackend.new

  before do
    # TODO: why doesn't this work with {} syntax for block?
    ServiceFactory.register :quotes_backend do
      @@fake_for_quotes
    end

    ServiceFactory.register :publications_backend do
      @@fake_for_pubs
    end

    ServiceFactory.register :users_backend do
      @@fake_for_users
    end
  end

  after do
    @@fake_for_quotes.reset
    @@fake_for_pubs.reset
    @@fake_for_users.reset
  end

  def quotes_gateway
    Quotes::Gateways::QuotesGateway.new @@fake_for_quotes
  end

  def publications_gateway
    Quotes::Gateways::PublicationsGateway.new @@fake_for_pubs
  end

  def users_gateway
    Users::Gateways::UserGateway.new @@fake_for_users
  end
end
