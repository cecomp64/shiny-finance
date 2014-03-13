

# http://ichart.finance.yahoo.com/table.csv?s=WWE&a=4&b=8&c=2009&d=3&e=6&f=2014&g=v&ignore=.csv
# http://www.jarloo.com/yahoo_finance/
# How to tell if a method is defined for an instance...
#  y.methods.include? :lookup_by_symbols

require 'open-uri'
require 'debug_logger'

class YahooFinanceScraper
  include LibHelpers

  def initialize()
    @headings = {name: 0, bid: 1, yield: 2, dividend: 3, change_amt: 4, change_pct: 5, volume: 6, eps: 7}
  end

  # Puts together a Yahoo query string for the given symbol
  # Symbol can be a list of symbols joined by a +
  # Returns nil on failure
  # TODO: Better error checking.
  def query_symbol(symbol)
    # Catch any exceptions from bad requests
    begin
      uri = open("http://finance.yahoo.com/d/quotes.csv?s=#{symbol}&f=nl1ydc6k2ve")
    rescue OpenURI::HTTPError=>e
      @logger.dbg_log(e)
      return nil
    end

    return uri
  end

  # Use Yahoo's CSV format to request stock info
  # http://finance.yahoo.com/d/quotes.csv?s=AAPL+GOOG+MSFT&f=nb3ydc6k2ve
  # Requesting, in order...
  #   name, bid, yield, dividend, change amount, change percent, volume, EPS
  def lookup_by_symbol(symbol)
    
    uri = query_symbol(symbol)
    if not uri
      return nil
    end

    csv_l = CSV.parse(uri.read)

    return parse_yahoo_csv(csv_l[0])
    end

  def parse_yahoo_csv(csv_l)
    details = {}
    
    #puts csv_l
    # Only expecting one row
    #csv_l.each do |yahoo|
      details["price"] = convert_dollar_amount(csv_l[@headings[:bid]])
      details["change_amt"] = convert_dollar_amount(csv_l[@headings[:change_amt]])
      details["change_pct"] = csv_l[@headings[:change_pct]]
      details["vol_avg"] = csv_l[@headings[:volume]]
      details["div_yield"] = csv_l[@headings[:yield]]
      details["eps"] = csv_l[@headings[:eps]]
      details["name"] = csv_l[@headings[:name]]
    #end

    return details
  end
  
  # Returns a list of details hash for each symbol
  # given by symbol_l
  def lookup_by_symbols(symbol_l)
    symbols = symbol_l.join("+")

    uri = query_symbol(symbols)
    if not uri
      return nil
    end

    details_l = []
    csv_l = CSV.parse(uri.read)

    csv_l.each do |symbol|
      details_l.append(parse_yahoo_csv(symbol))
    end

    return details_l
  end

  def lookup_by_symbol_and_exchange(symbol, exchange)
    lookup_by_symbol(symbol)
  end

end
