class AddTransferTransaction < ActiveRecord::Migration
  def up
    Action.create name: "transfer"

    transactions = Transaction.all
    transactions.each do |t|
      if t.action == nil and (t.description =~ /type:.*TRANSFER/i or t.description =~ /type:.*TRF BTWN/i)
        execute("UPDATE transactions SET action_id=#{Action.find_by_name("transfer").id} WHERE id=#{t.id}")
      end
    end
  end

  def down
    transactions = Transaction.all
    transfer = Action.find_by_name("transfer")
    transactions.each do |t|
      if t.action_id == transfer.id
        execute("UPDATE transactions SET action_id=NULL WHERE id=#{t.id}")
      end
    end
    transfer.delete
  end
end
