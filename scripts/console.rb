root = File.expand_path('..', __dir__)

unless ENV['RACK_ENV'] == 'production'
  require 'dotenv'

  Dotenv.load(
    *[
      ENV['RACK_ENV'] ? File.expand_path(".env.#{ENV['RACK_ENV']}", root) : nil,
      File.expand_path('.env', root)
    ].compact
  )
end

url = ENV['DATABASE_URL'].to_s
if url.match?(/heroku|amazonaws|rds\.|neon\.|supabase/i)
  warn <<~WARN

    WARNING: DATABASE_URL looks like production/hosted Postgres.
    For local dev use postgres:///quotes-development in .env

  WARN
end

boot = File.join(root, 'lib/boot.rb')
exec('bundle', 'exec', 'irb', '-r', boot)
