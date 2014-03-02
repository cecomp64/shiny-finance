class Lot < ActiveRecord::Base
  has_many :transactions
  belongs_to :user
  before_validation :check_only_one_symbol
  before_validation :compute_quantity
  validates :user, presence: true

  # buys = u.transactions.find_all_by_symbol_and_action_id("GE", Action.find_by_name("buy").id)
  # lot.transactions += buys

protected
  # Iterate through associated transactions
  # and make sure that we have not overspent
  # the available quantity
  def compute_quantity
    q = 0
    self.transactions.each do |trans|
      if (trans.action and trans.action.is_buy?)
        q += trans.quantity
      elsif (trans.action and trans.action.is_sell?)
        q -= trans.quantity
      end
    end

    self.quantity_remaining = q
    if self.quantity_remaining < 0
      self.errors.add(:quantity_remaining, 'Cannot sell transactions in a lot before.  Please add more buy transactions first.')
      return false
    end

    return true
  end

  # Make sure that there is only one kind of equity in this lot
  def check_only_one_symbol
    symbols = self.transactions.select(:symbol).distinct.count
    if (symbols > 1)
      self.errors.add(:symbol, "Lots can only contain one unique symbol.  Found #{symbols}")
      return false
    end

    return true
  end
end
