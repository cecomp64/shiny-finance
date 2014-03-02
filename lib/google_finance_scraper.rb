require 'open-uri'
require 'nokogiri'
require 'debug_logger'

# This class defines methods for querying stock information
# by scraping queries to the Google Finance webpage.
# 
# ==Examples
#
#   scraper = GoogleFinanceScraper.new()
#   # Get the price for stock NVDA on exchange NASDAQ
#   details = scraper.lookup_by_exchange_and_symbol("NASDAQ", "NVDA")
#   puts ("Name: #{details['name']} Price: #{details['price']} Change: #{details['change']}")

class GoogleFinanceScraper
  include LibHelpers

  # These are translations of headings in the Google Finance page to
  # more user-friendly hash names
  @@detail_keys = {"price"=> "price", "change_amt"=> "change_amt",
               "change_pct"=>"change_pct", "range"=> "range",
               "52 week"=>"year_range", "open"=>"open",
               "vol / avg."=>"vol_avg", "mkt cap"=>"market_cap",
               "p/e"=>"pe", "div/yield"=>"div_yield", "eps"=>"eps",
               "shares"=>"shares", "beta"=>"beta"}
  @@detail_keys.default = "unmapped"

  # Params:
  # [logging_mode] Sets the verbosity of debug messages
  def initialize(logging_mode = DebugLogger.modes[:silent])
    @logger = DebugLogger.new(logging_mode, "GogleFinanceScraper")
  end

  # Looks up a stock price given both the eschange and symbol information
  #
  # Params:
  # [exchnage] Which exchange the stock resides on.  i.e. NYSE or NASDAQ
  # [symbol] The ticker symbol for the stock.  i.e. AMD or NVDA
  #
  # Returns:
  # [details] A details hash with information about the stock.  Returns nil on failure
  def lookup_by_exchange_and_symbol(exchange, symbol)
    # Error check symbol
    if (symbol == nil or not symbol.is_a? String or symbol.strip.empty?)
      return nil
    end

    details = {}
    doc = Nokogiri::HTML(open("http://www.google.com/finance?q=#{exchange}:#{symbol}"))
    
    # Check for error
    # TODO: if we get close to a symobl, we get a "did you mean" message... need to fix
    err_div = doc.css('#app div#gf-viewc div')[6]
    err = nil
    if err_div != nil
      err = err_div.content
    end

    #err = doc.css('#app div#gf-viewc')[6].content
    if err and (err =~ /produced no matches/ or err =~ /Did you mean/)
      return nil
      end

    # Scrape out name
    details["name"] = doc.search('//meta[@itemprop="name"]').first['content']

    # Scrape out price and daily change
    t = doc.css('#price-panel')
    price = t[0].css('div span.pr span')[0].content.strip
    details["price"] = convert_dollar_amount(price)

    t = doc.css('.id-price-change span span')
    change_amt = t[0].content.strip
    details["change_amt"] = convert_dollar_amount(change_amt)
    details["change_pct"] = t[1].content.strip

    tr_l = doc.css('table.snap-data tr')
    
    # Scrape out other details
    for tr in tr_l
      td_l = tr.css('td')
      (key, val) = td_l
      mapped_key = @@detail_keys[key.content.strip.downcase] 
      @logger.dbg_log "mapped - #{mapped_key} unmapped - #{key.content.strip.downcase}\n"
      details[mapped_key] = val.content.strip
      end

    return details
  end

  # Looks up a stock by just its ticker symbol
  #
  # Params:
  # [symbol] The ticker symbol for a stock.  i.e. NVDA
  #
  # Returns:
  # [details] A details hash with information about the stock.  Returns nil on failure
  def lookup_by_symbol(symbol)
    # For now, let Google figure it out
    return self.lookup_by_exchange_and_symbol("", symbol)
  end

  # Parses csv files from Google Finance historical data
  #
  # Params:
  # [csv] A String object containing the csv data
  #
  # Returns:
  # [data] A list of lists.  Each entry contains a row in
  #        the csv.  The first entry contains the headings.
  def parse_csv(csv)
    # Return a list of rows
    # First row is header data
    data = []
    lines = csv.split("\n")

    for l in lines
      data.append(l.split(','))
    end

    return data
  end

  # Retrieves historical data for a given stock. Takes
  # parameters as a hash, since there can be many optional
  # parameters.
  #
  # Params:
  # [params] A hash of parameters with the following elements
  # * +:exchange+ - The exchange this stock is on.  i.e. NASDAQ
  # * +:symbol+ - The ticker symbol for this stock.
  # * +:start_date+ - Unimplemented
  # * +:end_date+ - Unimplemented
  def lookup_historical_data(params)
    exchange = params[:exchange]
    symbol = params[:symbol]

    # Catch any exceptions from bad requests
    begin
      uri = open("http://www.google.com/finance/historical?q=#{exchange}:#{symbol}&output=csv")
    rescue OpenURI::HTTPError=>e
      @logger.dbg_log(e)
      return nil
    end

    csv = uri.read

    # Fix Date string
    csv.sub!(/.*Date,/, "Date,")
    data = self.parse_csv(csv)
    @logger.dbg_log(data[1])
    return data
  end

end
