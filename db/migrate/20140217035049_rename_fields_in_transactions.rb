class RenameFieldsInTransactions < ActiveRecord::Migration
  def change
    change_table :transactions do |t|
      t.rename :Date, :date
      t.rename :Action, :action
      t.rename :Quantity, :quantity
      t.rename :Symbol, :symbol
      t.rename :Description, :description
      t.rename :Price, :price
      t.rename :Amount, :amount
      t.rename :Fees, :fees
    end
  end
end
