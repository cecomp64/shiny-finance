class Action < ActiveRecord::Base
  def is_buy?
    return (self.name == "buy")
  end

  def is_sell?
    return (self.name == "sell")
  end

  def is_dividend?
    return (self.name == "dividend")
  end

  def is_transfer?
    return (self.name == "transfer")
  end

  def is_interest?
    return (self.name == "interest")
  end

  def is_fee?
    return (self.name.singularize == "fee")
  end
end
