Sequel.migration do
  change do
    create_table(:quotes) do
      primary_key :id
      String      :author,      :null => false
      String      :title,       :null => false
      String      :content,     :null => false, :text => true
      String      :publisher
      String      :year
      String      :page_number
      String      :tags,        :text => true
    end
  end
end