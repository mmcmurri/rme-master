class CreateContractors < ActiveRecord::Migration
  def change
    create_table :contractors do |t|
      t.string :add
      t.string :name
      t.string :description
      t.date :servicedate
      t.integer :appro
      t.float :price
      t.timestamps null: false
    end
  end
end
