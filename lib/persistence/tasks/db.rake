namespace :db do
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

  desc "Run migrations (optionally include version number)"
  task :migrate do
    require "sequel"
    Sequel.extension :migration

    unless ENV.member?('DATABASE_URL')
      raise 'Please provide a database as `ENV[DATABASE_URL]`'
    end

    version = ENV['VERSION']
    database_url = ENV['DATABASE_URL']
    migration_dir = File.expand_path('../../../../migrations', __FILE__)
    db = Sequel.connect(database_url)

    if version
      puts "Migrating to version #{version}"
      Sequel::Migrator.run(db, migration_dir, :target => version.to_i)
    else
      puts "Migrating"
      Sequel::Migrator.run(db, migration_dir)
    end

    puts 'Migration complete'
  end
end
