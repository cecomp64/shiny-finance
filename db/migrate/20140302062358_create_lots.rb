class CreateLots < ActiveRecord::Migration
  def up
    create_table :lots do |t|
      t.integer :quantity_remaining, :null => false, :default=> 0
      t.timestamps
    end

    add_reference :lots, :user, index: true
    add_reference :transactions, :lot, index: true
  end

  def down
    drop_table :lots
    remove_column :transactions, :lot_id
  end
end
