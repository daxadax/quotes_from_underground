Sequel.migration do
  up do
    add_column :quotes, :added_by, Integer
  end

  down do
    drop_column :quotes, :added_by
  end
end
