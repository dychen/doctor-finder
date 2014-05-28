Sequel.migration do
  up do
    create_table(:doctors) do
      primary_key :id
      String :name, null: false
      String :specialty, null: false
      String :address, null: false
      unique [:name, :specialty, :address]
      index :name
      index :specialty
    end
  end
  down do
    drop_table(:doctor)
  end
end
