Sequel.migration do
  change do
    create_table(:users) do
      primary_key :uid
      String :nickname, :null => false
      String :email, :null => false
      String :auth_key, :null => false
      String :favorites, :text => true
      String :added, :text => true
      String :terms
    end
  end
end
