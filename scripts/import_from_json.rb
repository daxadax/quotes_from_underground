#!/usr/bin/env ruby
# Load production_data.json into the schema (migrations/001_initial_schema.rb).
#
# Usage:
#   ruby scripts/import_from_json.rb --migrate
#   ruby scripts/import_from_json.rb --truncate
#
# Defaults to DATABASE_URL, else postgres:///quotes-development
#
# Options:
#   --json PATH       default: data/production_data.json
#   --migrate         run migrations/ before import (empty database)
#   --truncate        delete all rows first

require 'json'
require 'optparse'
require 'sequel'
require 'securerandom'
require 'set'

ROOT = File.expand_path('..', __dir__)
MIGRATION_DIR = File.join(ROOT, 'migrations')

require File.join(ROOT, 'lib/content_normalizer')
DEFAULT_DATABASE_URL = 'postgres:///quotes-development'.freeze

module ImportFromJson
  module_function

  def load_export(path)
    JSON.parse(File.read(path))
  end

  def migrate!(db)
    Sequel.extension :migration
    Sequel::Migrator.run(db, MIGRATION_DIR)
  end

  def truncate!(db)
    %i[quote_links favorites quotes publications users].each do |table|
      db[table].delete
    end
  end

  def pg_tags(tags)
    Sequel.pg_array(Array(tags), :text)
  end

  def import!(db, export)
    counts = { users: 0, publications: 0, quotes: 0, favorites: 0, quote_links: 0 }
    user_uids = {}

    db.transaction do
      export['users'].each do |row|
        uid = SecureRandom.uuid
        user_uids[row['uid']] = uid
        db[:users].insert(
          uid: uid,
          nickname: row['nickname'],
          email: row['email'],
          auth_key: row['auth_key'],
          last_login_address: row['last_login_address'],
          last_login_time: row['last_login_time'],
          login_count: row['login_count'] || 0
        )
        counts[:users] += 1
      end

      export['publications'].each do |row|
        db[:publications].insert(
          publication_uid: row['publication_uid'],
          added_by: user_uids.fetch(row['publication_added_by']),
          author: row['author'],
          title: row['title'],
          publisher: row['publisher'],
          year: row['year']
        )
        counts[:publications] += 1
      end

      export['quotes'].each do |row|
        db[:quotes].insert(
          uid: row['uid'],
          added_by: user_uids.fetch(row['added_by']),
          publication_uid: row['publication_uid'],
          content: ContentNormalizer.normalize(row['content']),
          page_number: row['page_number'],
          tags: pg_tags(row['tags'])
        )
        counts[:quotes] += 1
      end

      quote_uids = export['quotes'].map { |row| row['uid'] }.to_set

      export['users'].each do |row|
        user_uid = user_uids.fetch(row['uid'])
        Array(row['favorites']).each do |quote_uid|
          next unless quote_uids.include?(quote_uid)

          db[:favorites].insert(user_uid: user_uid, quote_uid: quote_uid)
          counts[:favorites] += 1
        end
      end

      export['quotes'].each do |row|
        Array(row['links']).each do |linked_uid|
          next unless quote_uids.include?(linked_uid)
          next if row['uid'] == linked_uid

          db[:quote_links].insert(quote_uid: row['uid'], linked_quote_uid: linked_uid)
          counts[:quote_links] += 1
        end
      end
    end

    rebuild_search!(db)
    sync_id_sequences!(db)
    counts
  end

  # Explicit uid inserts do not advance PG sequences; bump after bulk import.
  def sync_id_sequences!(db)
    row = db.fetch(<<~SQL).first
      SELECT EXISTS (
        SELECT 1 FROM pg_class WHERE relname = 'quotes_uid_seq'
      ) AS ok
    SQL
    return unless row && row[:ok]

    max_quote = db[:quotes].max(:uid) || 0
    max_pub = db[:publications].max(:publication_uid) || 0
    db.run("SELECT setval('quotes_uid_seq', #{max_quote + 1}, false)")
    db.run("SELECT setval('publications_publication_uid_seq', #{max_pub + 1}, false)")
  end

  def rebuild_search!(db)
    return unless db.table_exists?(:quote_tags)

    db[:quote_tags].delete
    db.run(<<~SQL)
      INSERT INTO quote_tags (quote_uid, tag)
      SELECT DISTINCT q.uid, tag
      FROM quotes q, unnest(q.tags) AS tag;
    SQL

    return unless db.schema(:quotes).map(&:first).include?(:content_tsv)

    db[:quotes].each do |row|
      content = ContentNormalizer.normalize(row[:content])
      tsv = db.get(Sequel.lit("to_tsvector('english', ?)", content))
      db[:quotes].where(uid: row[:uid]).update(content: content, content_tsv: tsv)
    end
  end

  def verify!(db, export)
    checks = []
    checks << [:users, db[:users].count, export['users'].size]
    checks << [:publications, db[:publications].count, export['publications'].size]
    checks << [:quotes, db[:quotes].count, export['quotes'].size]

    checks.each do |table, actual, expected|
      abort("count mismatch for #{table}: #{actual} != #{expected}") unless actual == expected
    end

    quote = db[:quotes].where(uid: 119).first
    abort('quote 119 missing') unless quote
    abort('quote 119 tags mismatch') unless quote[:tags].include?('groups of i"s')

    content = db[:quotes].where(uid: 11).get(:content)
    abort('quote 11 content mismatch') unless content&.include?("\n\n")
    abort('quote 11 still has literal escape sequences') if content&.include?('\\n')

    dax = db[:users].where(nickname: 'dax').first
    abort('user dax missing') unless dax
    abort('dax uid must be uuid') unless dax[:uid].to_s.match?(/\A[0-9a-f-]{36}\z/i)
    abort('dax favorites missing') unless db[:favorites].where(user_uid: dax[:uid]).count.positive?

    checks
  end
end

if __FILE__ == $PROGRAM_NAME
  options = {
    json: File.join(ROOT, 'data', 'production_data.json'),
    migrate: false,
    truncate: false
  }

  OptionParser.new do |opts|
    opts.on('--json PATH', "JSON export (default: #{options[:json]})") { |path| options[:json] = path }
    opts.on('--migrate', 'Run migrations first') { options[:migrate] = true }
    opts.on('--truncate', 'Truncate tables before import') { options[:truncate] = true }
  end.parse!

  database_url = ENV['DATABASE_URL'] || DEFAULT_DATABASE_URL
  abort("JSON not found: #{options[:json]}") unless File.file?(options[:json])

  db = Sequel.connect(database_url)
  db.extension :pg_array

  ImportFromJson.migrate!(db) if options[:migrate]
  ImportFromJson.truncate!(db) if options[:truncate]

  export = ImportFromJson.load_export(options[:json])
  counts = ImportFromJson.import!(db, export)
  ImportFromJson.verify!(db, export)

  puts 'Import complete'
  counts.each { |table, n| puts "  #{table}: #{n}" }
end
