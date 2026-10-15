require 'sequel'
require 'bcrypt'

DB =
  if defined?(DATABASE_CONNECTION) && DATABASE_CONNECTION
    DATABASE_CONNECTION
  else
    Sequel.connect(ENV.fetch('DATABASE_URL', 'postgres:///quotes-development'))
  end
DB.extension :pg_array
Sequel::Model.db = DB

require_relative 'write_result'
require_relative 'content_normalizer'

Dir[File.join(__dir__, 'models', '*.rb')].sort.each { |path| require path }

require_relative 'queries/quote_search'
require_relative 'queries/similar_quotes'
require_relative 'kindle_import'
