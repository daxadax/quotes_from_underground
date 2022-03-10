Sequel.migration do
  up do
    add_column :quotes, :starred, TrueClass
    add_column :quotes, :links,   String, :text => true
  end

  down do
    drop_column :quotes, :starred
    drop_column :quotes, :links
  end
end
