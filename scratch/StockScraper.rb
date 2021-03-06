require 'open-uri'
require 'nokogiri'

class GoogleFinanceScraper

  @@detail_keys = {"price"=> "price", "change_amt"=> "change_amt",
               "change_pct"=>"change_pct", "range"=> "range",
               "52 week"=>"year_range", "open"=>"open",
               "vol / avg."=>"vol_avg", "mkt cap"=>"market_cap",
               "p/e"=>"pe", "div/yield"=>"div_yield", "eps"=>"eps",
               "shares"=>"shares", "beta"=>"beta"}
  @@detail_keys.default = "unmapped"

  def initialize()
  end

  def lookup_by_exchange_and_symbol(exchange, symbol)
    details = {}
    doc = Nokogiri::HTML(open("http://www.google.com/finance?q=#{exchange}:#{symbol}"))
    
    # Check for error
    err = doc.css('#app div#gf-viewc div')[6].content
    if err and err =~ /produced no matches/
      return nil
      end

    # Scrape out name
    details["name"] = doc.search('//meta[@itemprop="name"]').first['content']

    # Scrape out price and daily change
    t = doc.css('#price-panel')
    details["price"] = t[0].css('div span.pr span')[0].content.strip

    t = doc.css('.id-price-change span span')
    details["change_amt"] = t[0].content.strip
    details["change_pct"] = t[1].content.strip

    tr_l = doc.css('table.snap-data tr')
    
    # Scrape out other details
    for tr in tr_l
      td_l = tr.css('td')
      (key, val) = td_l
      mapped_key = @@detail_keys[key.content.strip.downcase] 
      puts "DBG: mapped - #{mapped_key} unmapped - #{key.content.strip.downcase}\n"
      details[mapped_key] = val.content.strip
      end

    return details
  end

  def lookup_by_symbol(symbol)
    # For now, let Google figure it out
    return self.lookup_by_exchange_and_symbol("", symbol)
  end
end
