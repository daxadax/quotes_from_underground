require 'minitest/autorun'
require 'sequel'
require_relative '../scripts/import_from_json'

describe ImportFromJson do
  describe 'integration' do
    it 'imports production_data.json losslessly' do
      url = ENV['DATABASE_URL'] || 'postgres:///quotes-development'
      db = Sequel.connect(url)
      db.extension :pg_array

      ImportFromJson.migrate!(db)
      ImportFromJson.truncate!(db)

      export = ImportFromJson.load_export(
        File.expand_path('../data/production_data.json', __dir__)
      )
      ImportFromJson.import!(db, export)
      ImportFromJson.verify!(db, export)

      quote = db[:quotes].where(uid: 11).first
      assert quote[:content].include?("\n\n")
      refute_includes quote[:content], '\\n'

      tag = db[:quotes].where(uid: 119).first[:tags].find { |t| t.include?('"') }
      assert tag.include?('groups of i"s')
    end
  end
end
