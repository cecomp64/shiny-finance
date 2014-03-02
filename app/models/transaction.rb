class Transaction < ActiveRecord::Base
  belongs_to :user
  belongs_to :action
  belongs_to :lot
end
