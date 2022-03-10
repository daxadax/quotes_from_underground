Sequel.migration do
  up do
    add_column :users, :last_login_address, String
    add_column :users, :last_login_time, Integer
    add_column :users, :login_count, Integer
  end

  down do
    drop_column :users, :last_login_address
    drop_column :users, :last_login_time
    drop_column :users, :login_count
  end
end
