Sequel.migration do
  change do
    create_table(:users) do
      uuid :uid, primary_key: true, default: Sequel.lit('gen_random_uuid()')
      String :nickname, text: true, null: false, unique: true
      String :email, text: true, null: false
      String :auth_key, text: true, null: false
      String :terms
      String :last_login_address, text: true
      Integer :last_login_time
      Integer :login_count, default: 0
    end

    create_table(:publications) do
      Integer :publication_uid, primary_key: true
      foreign_key :added_by, :users, type: :uuid, key: :uid, null: false
      String :author, text: true, null: false
      String :title, text: true, null: false
      String :publisher, text: true
      Integer :year, null: false
      index [:author, :title]
    end

    create_table(:quotes) do
      Integer :uid, primary_key: true
      foreign_key :added_by, :users, type: :uuid, key: :uid, null: false
      foreign_key :publication_uid, :publications, type: Integer, null: false
      Text :content, null: false
      String :page_number, text: true
      column :tags, 'text[]', default: Sequel.lit("'{}'")
      index :added_by
      index :publication_uid
    end

    run 'CREATE INDEX quotes_tags_gin ON quotes USING GIN (tags)'

    create_table(:favorites) do
      foreign_key :user_uid, :users, type: :uuid, key: :uid, null: false, on_delete: :cascade
      foreign_key :quote_uid, :quotes, type: Integer, key: :uid, null: false, on_delete: :cascade
      primary_key [:user_uid, :quote_uid]
    end

    create_table(:quote_links) do
      foreign_key :quote_uid, :quotes, type: Integer, key: :uid, null: false, on_delete: :cascade
      foreign_key :linked_quote_uid, :quotes, type: Integer, key: :uid, null: false, on_delete: :cascade
      primary_key [:quote_uid, :linked_quote_uid]
      check Sequel.lit('quote_uid <> linked_quote_uid')
    end
  end
end
