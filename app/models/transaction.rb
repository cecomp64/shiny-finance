class Transaction < ActiveRecord::Base
  belongs_to :user
  belongs_to :action
  belongs_to :lot

  validates_associated :lot

  def to_csv(first)
    csv_str = ""
    if first
      csv_str += "Date,Action,Quantity,Symbol,Description,Price,Amount,Fees\n"
    end

    csv_str += "%s,%s,%d,%s,%s,%f,%f,%f\n" % [self.date.strftime("%m/%d/%Y"), self.action ? self.action.name.capitalize : "", 
                                          self.quantity, self.symbol.upcase, self.description, self.price, self.amount, self.fees]

    return csv_str
  end
end
