class CreateActions < ActiveRecord::Migration
  def change
    create_table :actions do |t|
      t.string :name
      t.index :name, unique: true
    end

    Action.create :name => "buy"
    Action.create :name => "sell"
    Action.create :name => "dividend"
    Action.create :name => "interest"

  end
end
