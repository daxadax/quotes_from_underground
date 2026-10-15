ROOT = File.expand_path('..', __dir__)
require File.join(ROOT, 'lib/content_normalizer')

Sequel.migration do
  up do
    run 'CREATE SEQUENCE quotes_uid_seq'
    run 'CREATE SEQUENCE publications_publication_uid_seq'

    run <<~SQL
      SELECT setval('quotes_uid_seq', COALESCE((SELECT MAX(uid) FROM quotes), 0) + 1, false);
      SELECT setval('publications_publication_uid_seq', COALESCE((SELECT MAX(publication_uid) FROM publications), 0) + 1, false);
    SQL

    alter_table(:quotes) do
      set_column_default :uid, Sequel.lit("nextval('quotes_uid_seq')")
    end

    alter_table(:publications) do
      set_column_default :publication_uid, Sequel.lit("nextval('publications_publication_uid_seq')")
    end

    create_table(:quote_tags) do
      foreign_key :quote_uid, :quotes, type: Integer, key: :uid, null: false, on_delete: :cascade
      String :tag, text: true, null: false
      index %i[quote_uid tag], unique: true
      index :tag
    end

    add_column :quotes, :content_tsv, 'tsvector'

    from(:quotes).each do |row|
      content = ContentNormalizer.normalize(row[:content])
      tsv = get(Sequel.lit("to_tsvector('english', ?)", content))
      from(:quotes).where(uid: row[:uid]).update(content: content, content_tsv: tsv)
    end

    run <<~SQL
      INSERT INTO quote_tags (quote_uid, tag)
      SELECT DISTINCT q.uid, tag
      FROM quotes q, unnest(q.tags) AS tag;
    SQL

    run 'CREATE INDEX quotes_content_tsv_gin ON quotes USING GIN (content_tsv)'
  end

  down do
    run 'DROP INDEX IF EXISTS quotes_content_tsv_gin'
    drop_column :quotes, :content_tsv
    drop_table :quote_tags

    alter_table(:quotes) { set_column_default :uid, nil }
    alter_table(:publications) { set_column_default :publication_uid, nil }

    run 'DROP SEQUENCE IF EXISTS quotes_uid_seq'
    run 'DROP SEQUENCE IF EXISTS publications_publication_uid_seq'
  end
end
