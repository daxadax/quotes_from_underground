require 'sequel'

ENV['DATABASE_URL'] = 'postgres://hagbard@localhost:5432/quotes-test'

class GatewayBackendSpec < FakeGatewayAccess
  before do
    Persistence::Gateways::Backend::DATABASE_CONNECTION = database
    clean_database
    run_migrations
  end

  def clean_database
    existing_tables = database.tables
    tables_to_preserve = [:schema_info, :schema_migrations]
    tables_to_be_emptied  = existing_tables - tables_to_preserve

    tables_to_be_emptied.each { |table| database << "TRUNCATE #{table}" }
  end

  def run_migrations
    Sequel.extension :migration

    Sequel::Migrator.apply(database, "./migrations/")
  end

  def database
    @database ||= Sequel.connect(ENV.fetch("DATABASE_URL"))
  end
end
