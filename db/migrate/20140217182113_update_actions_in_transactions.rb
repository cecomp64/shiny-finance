class UpdateActionsInTransactions < ActiveRecord::Migration
  def up
    change_table :transactions do |t|
      t.belongs_to :action
    end

    # Make existing actions key into actions table
    actions = Action.all
    actions.each do |a|
      execute("UPDATE transactions SET action_id=#{a.id} WHERE action LIKE '%#{a.name}%'")
    end

    remove_column :transactions, :action
  end

  def down
    add_column :transactions, :action

    # Get as close to the original action as we can...
    actions = Action.all
    actions.each do |a|
      execute("UPDATE transactions SET action = '#{a.name.capitalize}' WHERE action_id=#{a.id}")
    end

    remove_column :transactions, :action_id
  end
end
