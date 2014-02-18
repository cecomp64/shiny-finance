class AddFeeToActions < ActiveRecord::Migration
  def change
    Action.create name: "fees"
  end
end
