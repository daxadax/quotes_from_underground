#!/usr/bin/env ruby
# Convert a Heroku/pg_dump custom-format backup to JSON.
#
# Usage:
#   ruby scripts/dump_to_json.rb
#   ruby scripts/dump_to_json.rb path/to/production.dump path/to/production_data.json
#   ruby scripts/dump_to_json.rb --all-users   # include bot registrations

require 'json'
require 'open3'
require 'optparse'
require 'set'
require 'time'

ROOT = File.expand_path('..', __dir__)

TABLES = {
  'publications' => %w[
    publication_uid author title publisher year publication_added_by
  ],
  'quotes' => %w[
    uid content page_number tags links added_by publication_uid
  ],
  'users' => %w[
    uid nickname email auth_key favorites
    last_login_address last_login_time login_count
    added_quotes added_publications
  ],
  'schema_info' => %w[version]
}.freeze

JSON_COLUMNS = {
  'quotes' => %w[tags links],
  'users' => %w[favorites added_quotes added_publications]
}.freeze

INTEGER_COLUMNS = {
  'publications' => %w[publication_uid year publication_added_by],
  'quotes' => %w[uid added_by publication_uid],
  'users' => %w[uid last_login_time login_count],
  'schema_info' => %w[version]
}.freeze

def usage!
  warn 'Usage: ruby scripts/dump_to_json.rb [dump_file] [output_json]'
  exit 1
end

def pg_restore_sql(dump_path)
  sql, status = Open3.capture2('pg_restore', '-f', '-', dump_path)
  abort("pg_restore failed: #{status.exitstatus}") unless status.success?

  sql
end

def copy_rows(sql, table)
  pattern = /COPY "public"."#{table}"[^\n]*\n(.*?)\n\\\./m
  block = sql[pattern, 1]
  return [] unless block

  block.each_line.map { |line| line.chomp.split("\t", -1) }
end

def null_value?(value)
  value.nil? || value == '\N' || value.empty?
end

# pg_dump COPY text escapes backslashes; JSON columns need unescaping first.
def unescape_copy(value)
  value.gsub(/\\(.)/m) do
    case Regexp.last_match(1)
    when 'n' then "\n"
    when 'r' then "\r"
    when 't' then "\t"
    when 'b' then "\b"
    when 'f' then "\f"
    when '\\' then '\\'
    else Regexp.last_match(1)
    end
  end
end

def cast_value(table, column, value)
  return nil if null_value?(value)

  value = unescape_copy(value)

  if JSON_COLUMNS.fetch(table, []).include?(column)
    JSON.parse(value)
  elsif INTEGER_COLUMNS.fetch(table, []).include?(column)
    value.to_i
  else
    value
  end
end

def rows_to_hashes(table, rows)
  columns = TABLES.fetch(table)

  rows.map do |row|
    columns.each_with_index.to_h do |column, index|
      [column, cast_value(table, column, row[index])]
    end
  end
end

def real_user?(user)
  return true if (user['login_count'] || 0).positive?

  %w[favorites added_quotes added_publications].any? do |field|
    Array(user[field]).any?
  end
end

def filter_users(users, quotes:, publications:)
  referenced = quotes.map { |row| row['added_by'] }.compact
  referenced.concat(publications.map { |row| row['publication_added_by'] })
  keep_uids = referenced.to_set

  users.select { |user| keep_uids.include?(user['uid']) || real_user?(user) }
end

def build_export(dump_path, sql, all_users: false)
  tables = TABLES.each_with_object({}) do |(table, _), result|
    result[table] = rows_to_hashes(table, copy_rows(sql, table))
  end

  unless all_users
    tables['users'] = filter_users(
      tables['users'],
      quotes: tables['quotes'],
      publications: tables['publications']
    )
  end

  {
    'exported_at' => Time.now.utc.iso8601,
    'source' => dump_path,
    'schema_version' => tables['schema_info'].first&.fetch('version'),
    'counts' => {
      'publications' => tables['publications'].size,
      'quotes' => tables['quotes'].size,
      'users' => tables['users'].size
    },
    'publications' => tables['publications'],
    'quotes' => tables['quotes'],
    'users' => tables['users']
  }
end

options = { all_users: false }
parser = OptionParser.new do |opts|
  opts.on('--all-users', 'Include bot/spam registrations') { options[:all_users] = true }
end

paths = parser.parse!
dump_path = File.expand_path(paths[0] || File.join(ROOT, 'data', 'production.dump'))
output_path = File.expand_path(paths[1] || File.join(File.dirname(dump_path), 'production_data.json'))

usage! unless File.file?(dump_path)

export = build_export(dump_path, pg_restore_sql(dump_path), all_users: options[:all_users])

File.write(output_path, JSON.pretty_generate(export))

puts "Wrote #{output_path}"
puts "  publications: #{export['counts']['publications']}"
puts "  quotes:       #{export['counts']['quotes']}"
puts "  users:        #{export['counts']['users']}"
puts "  schema:       v#{export['schema_version']}"
