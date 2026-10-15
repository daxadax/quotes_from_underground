Sequel.migration do
  change do
    drop_column :users, :terms
  end
end
