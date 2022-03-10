Sequel.migration do
  up do
    drop_column :users, :added
    add_column :users, :added_quotes, String, :text => true
    add_column :users, :added_publications, String, :text => true
  end

  down do
    add_column :users, :added, String, :text => true
    drop_column :users, :added_quotes
    drop_column :users, :added_publications
  end
end
