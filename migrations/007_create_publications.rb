Sequel.migration do
  change do
    create_table(:publications) do
      primary_key :uid
      String :author, :null => false
      String  :title, :null => false
      String  :publisher
      Integer :year, :null => false
    end
  end
end
