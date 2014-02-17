module LibHelpers
  # Handle the formatting of dollar amounts.  Remove dollar sign, and
  # turn parentheses into negative numbers.  Returns a float of the amount.
  # Assumes that any commas have already been removed.
  #
  # [($0.35)] Becomes [-0.35]
  #
  # Params:
  # [amt_s] A string representation of the amount to convert.
  def convert_dollar_amount(amt_s)
    # If amt is nil or not a string, we can't parse
    if amt_s != nil and amt_s.is_a? String
      # Replace parentheses with minus sign
      amt_s.sub!(/\((.*)\)/, '-\1')
      # Remove $
      amt_s.sub!(/\$/, '')
      # Remove commas
      amt_s.gsub!(/,/, '')
      return amt_s.to_f
    end

    return amt_s
  end
end
