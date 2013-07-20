class CreateStocks < ActiveRecord::Migration
  def change
    create_table :stocks do |t|
      t.string :code
      t.string :name
      t.float :price
      t.date :lastdate

      t.timestamps
    end
  end
end
