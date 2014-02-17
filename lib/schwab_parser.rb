require 'open-uri'
require 'debug_logger'
require 'csv'

# Contains logic to parse and format data from Schwab transactions
# into shiny-finance transactions.
class SchwabParser
  include LibHelpers

  @csv = nil
  @transactions = []

  attr_accessor :date_pos, :action_pos, :quantity_pos, :symbol_pos, :desc_pos, :price_pos, :amount_pos, :fees_pos

  def initialize(logging_mode = DebugLogger.modes[:silent])
    @date_pos = 0
    @action_pos = 1
    @quantity_pos = 2
    @symbol_pos = 3
    @desc_pos = 4
    @price_pos = 5
    @amount_pos = 6
    @fees_pos = 7
    @logger = DebugLogger.new(logging_mode)
  end

  # Open the csv transaction data from a URL.  Returns the csv data as a string.
  # Params:
  # [url] link to csv transaction data
  def open_url(url)
    begin
      uri = open(url)
    rescue OpenURI::HTTPError=>e
      @logger.dbg_log(e)
      @csv = nil
      return nil
    end
    @csv = uri.read
  end

  # Open the csv transaction data from a file.  Returns the csv data as a string.
  # Params:
  # [file] path to csv transaction data
  def open_file(file)
    begin
      @csv = File.read(file)
    rescue
      @csv = nil
    end

    return @csv
  end

  # Returns a properly formatted Date object
  # for insertion to database
  def parse_date(date_s)
    # Remove any additional date clarification
    if date_s != nil
      date_s.sub!(/(.*) as of.*/, '\1')
      # Check for a two-digit date or a four-digit date
      match = date_s.match(/(\d+)\/(\d+)\/(\d+)/)
      if (match)
        match_l = match.captures
        # Check the year for two or four digits
        if(match_l[2].size == 4)
          return Date.strptime(date_s, "%m/%d/%Y")
        elsif(match_l[2].size == 2)
          return Date.strptime(date_s, "%m/%d/%y")
        else
          return nil
        end
      else # Not in a format we expected
        return nil
      end
    else # Received a nil parameter
      return nil
    end
    return date
  end

  # Returns the qualified action for this transaction
  # Uses the entire entry to find an action in the description
  # if one is not explicitly listed
  def parse_action(entry)
    action = entry[@action_pos]
    if action == nil
      # Look for an action in the description
      desc = entry[@desc_pos]
      if (desc =~ /type:.* DIV/)
        action = "Dividend"
      elsif (desc =~ /type:.* FEE/)
        action = "Fee"
      end
    end

    return action
  end

  def parse_fees(entry, action)
    fees = convert_dollar_amount(entry[@fees_pos])
    amount = convert_dollar_amount(entry[@amount_pos])

    # Level-set the fees amount
    if fees == nil
      fees = 0.0
    end

    # Add the amount of a fee into the Fees column for consistency
    if action and action.match(/fee/i) and amount != nil and fees != -amount
      @logger.dbg_log("Calculating Fees for entry #{entry.to_s}")
      @logger.dbg_log("  Converting fee action - #{action} amt - #{amount} fees - #{fees}")
      
      # A fee will be a negative amount.  In order to keep the Fees column
      # positive, reverse the sign here
      fees = fees - amount
    end

    return fees
  end

  # Return the quantity field as a number
  def parse_quantity(quantity_s)
    if quantity_s != nil
      return quantity_s.to_f
    end

    return quantity_s
  end

  # Some versions of schwab data are jumbled,
  # dynamically figure out the order of the data based
  # on the headers in this CSV
  def parse_headers(headers)
    headers.each_index do |idx|
      if headers[idx]
        if headers[idx].match(/Date/i)
          @date_pos = idx
        elsif headers[idx].match(/Action/i)
          @action_pos = idx
        elsif headers[idx].match(/quantity/i)
          @quantity_pos = idx
        elsif headers[idx].match(/symbol/i)
          @symbol_pos = idx
        elsif headers[idx].match(/description/i)
          @desc_pos = idx
        elsif headers[idx].match(/price/i)
          @price_pos = idx
        elsif headers[idx].match(/amount/i)
          @amount_pos = idx
        elsif headers[idx].match(/fees/i)
          @fees_pos = idx
        end
      end
    end
  end

  # Parse the raw csv transaction data from Schwab.
  # Takes passes to recategorize and cleanup formatting.
  # Returns a transaction hash.
  # Params:
  # [csv] Optional csv data.  By default uses @csv.  Must open file first.
  def parse(csv = @csv)
    #csv_t = CSV.parse(csv, {:headers => true})
    csv_l = CSV.parse(csv)
    if not csv_l
      return nil
      end

    # First row is some kind of non-csv heading
    csv_l.slice!(0)
    headers = csv_l.slice!(0)
    parse_headers(headers)
    transactions = []

    # Iterate over each entry.  They should be, in order:
    # Date  Action  Quantity  Symbol  Description Price Amount  Fees & Comm
    csv_l.each do |entry|
      @logger.dbg_log(entry.to_s)
      transaction = {}
      transaction[:Date] = parse_date(entry[@date_pos])
      transaction[:Action] = parse_action(entry)
      transaction[:Quantity] = parse_quantity(entry[@quantity_pos])
      transaction[:Symbol] = entry[@symbol_pos]
      transaction[:Description] = entry[@desc_pos]
      transaction[:Price] = convert_dollar_amount(entry[@price_pos])
      transaction[:Amount] = convert_dollar_amount(entry[@amount_pos])
      # Parse fees after action, because action may alter the fees column
      transaction[:Fees] = parse_fees(entry, transaction[:Action])

      transactions.append(transaction)
    end

    return transactions
  end

end
