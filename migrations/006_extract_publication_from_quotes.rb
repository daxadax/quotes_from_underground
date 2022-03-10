Sequel.migration do
  up do
    drop_column   :quotes, :author
    drop_column   :quotes, :title
    drop_column   :quotes, :publisher
    drop_column   :quotes, :year
    add_column :quotes, :publication_uid, Integer
  end

  down do
    add_column   :quotes, :author, String
    add_column   :quotes, :title, String
    add_column   :quotes, :publisher, String
    add_column   :quotes, :year, String
    drop_column :quotes, :publication_uid
  end
end
