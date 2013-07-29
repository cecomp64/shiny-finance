class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.date :Date
      t.text :Action
      t.integer :Quantity
      t.string :Symbol
      t.text :Description
      t.float :Price
      t.float :Amount
      t.float :Fees

      t.timestamps
    end
  end
end
