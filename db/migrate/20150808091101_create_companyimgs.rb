class CreateCompanyimgs < ActiveRecord::Migration
  def change
    create_table :companyimgs do |t|
      t.string :name
      t.string :logo
      t.string :certi1
      t.string :certi2
      t.string :carousel

      t.timestamps null: false
    end
  end
end
