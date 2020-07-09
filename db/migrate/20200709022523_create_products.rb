class CreateProducts < ActiveRecord::Migration[6.0]
  def change
    create_table :products do |t|
      t.string :name
      t.string :price
      t.text :description
      t.text :extra_information

      t.timestamps
    end
    add_index :products, :name, unique: true
    add_index :products, :price
  end
end
