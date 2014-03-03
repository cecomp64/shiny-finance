class Lot < ActiveRecord::Base
  has_many :transactions
  belongs_to :user
  validates :user, presence: true

  # buys = u.transactions.find_all_by_symbol_and_action_id("GE", Action.find_by_name("buy").id)
  # lot.transactions += buys

  # Does some validations to check if the new set
  # of transactions will play nicely.  Checks what
  # new remaining quantity would be, and uniqueness
  # of symbols
  def add_transactions(new_trans)
    q_result = compute_quantity(new_trans)
    self.quantity_remaining = q_result[:quantity]
    sym_result = check_only_one_symbol(new_trans)

    # Add the new transactions if everything checks out
    if (sym_result and q_result[:valid])
      self.transactions += new_trans
      return true
    else
      return false
    end
  end
protected
  # Iterate through associated transactions
  # and make sure that we have not overspent
  # the available quantity
  def compute_quantity(new_trans)
    q = 0
    check_trans = self.transactions + new_trans
    check_trans.each do |trans|
      if (trans.action and trans.action.is_buy?)
        q += trans.quantity
      elsif (trans.action and trans.action.is_sell?)
        q -= trans.quantity
      end
    end

    if q < 0
      self.errors.add(:quantity_remaining, 'Cannot sell more transactions than have been bought.  Please add more buys first')
      return {valid: false, quantity: self.quantity_remaining}
    end

    return {valid: true, quantity: q}
  end

  # Make sure that there is only one kind of equity in this lot
  def check_only_one_symbol(new_trans)
    checklist = self.transactions + new_trans
    symbols = checklist.uniq{|c| c.symbol.upcase.strip}.count
    if (symbols > 1)
      self.errors.add(:symbol, "Lots can only contain one unique symbol.  Found #{symbols}.")
      return false
    end

    return true
  end
end
