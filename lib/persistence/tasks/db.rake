namespace :db do
  DEV_DATABASE = 'quotes-development'.freeze
  TASKS_DIR = File.dirname(__FILE__)

  desc "Drop database for environment in DB_ENV for DB_USER"
  task :drop do
    unless ENV.member?('DB_ENV')
      raise 'Please provide the environment to create for as `ENV[DB_ENV]`'
    end

    env = ENV['DB_ENV']
    user = ENV['DB_USER']

    `dropdb -U #{user} quotes-#{env}`
    print "Database quotes-#{env} dropped successfully\n"
  end

  desc "Create database for environment in DB_ENV for DB_USER"
  task :create do
    unless ENV.member?('DB_ENV')
      raise 'Please provide the environment to create for as `ENV[DB_ENV]`'
    end

    env = ENV['DB_ENV']
    user = ENV['DB_USER']

    `createdb -p 5432 -U #{user} quotes-#{env}`
    print "Database quotes-#{env} created successfully\n"
  end

  desc "Run migrations on quotes-development (or DATABASE_URL)"
  task :migrate do
    require 'sequel'
    Sequel.extension :migration

    url = ENV['DATABASE_URL'] || "postgres:///#{DEV_DATABASE}"
    migration_dir = File.expand_path('../../../migrations', TASKS_DIR)
    db = Sequel.connect(url)

    puts "Migrating #{url}"
    if ENV['VERSION']
      Sequel::Migrator.run(db, migration_dir, target: ENV['VERSION'].to_i)
    else
      Sequel::Migrator.run(db, migration_dir)
    end

    puts 'Migration complete'
  end

  desc 'Import data/production_data.json (DATABASE_URL or quotes-development)'
  task :import do
    url = ENV['DATABASE_URL'] || "postgres:///#{DEV_DATABASE}"
    exec({ 'DATABASE_URL' => url }, 'ruby',
         File.expand_path('../../../scripts/import_from_json.rb', TASKS_DIR),
         '--truncate', *ARGV)
  end
end
