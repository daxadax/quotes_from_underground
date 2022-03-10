Sequel.migration do
  up do
    add_column :publications, :publication_added_by, Integer
  end

  down do
    drop_column :publications, :publication_added_by
  end
end
