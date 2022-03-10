Sequel.migration do
  up do
    rename_column :quotes, :id, :uid
    drop_column   :quotes, :starred
  end

  down do
    rename_column :quotes, :uid, :id
    add_column    :quotes, :starred, String, :text => true
  end
end
