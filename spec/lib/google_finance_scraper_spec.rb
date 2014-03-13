require 'spec_helper'
require 'google_finance_scraper'

describe GoogleFinanceScraper do
  scraper = GoogleFinanceScraper.new(DebugLogger.modes[:debug])
  subject {scraper}

  describe "Valid queries with Exchange and Symbol" do
    details_nvd = scraper.lookup_by_exchange_and_symbol("NASDAQ", "NVDA")
    it "NASDAQ:NVDA should have a valid name field" do
      name = details_nvd["name"]
      expect(name).to eq("NVIDIA Corporation")
    end

    it "Should have a numeric price" do
      price = details_nvd["price"]
      expect(price.is_a? Float).to eq(true)
      expect(price > 0.0).to eq(true)
    end

    details_amd = scraper.lookup_by_exchange_and_symbol("NYSE", "AMD")
    it "NYSE:AMD should have a valid name field" do
      name = details_amd["name"]
      expect(name).to eq("Advanced Micro Devices, Inc.")
    end
  end

  describe "Query with Ambiguous Symbol" do
    details = scraper.lookup_by_exchange_and_symbol("NASDAQ", "NVD")
    it "should return nil" do
      expect(details).to eq(nil)
    end
  end

  describe "Query with bogus Symbol" do
    details = scraper.lookup_by_exchange_and_symbol("NASDAQ", "POOP")
    it "should return nil" do
      expect(details).to eq(nil)
    end
  end

  describe "Query with only valid symbol" do
    details_nvd = scraper.lookup_by_symbol("NVDA")
    it "NVDA should have a valid name field" do
      name = details_nvd["name"]
      expect(name).to eq("NVIDIA Corporation")
    end
  end

  describe "Get historical data with valid data" do
    details_amd = scraper.lookup_historical_data(:symbol=>"AMD")
    it "AMD should have a valid header" do
      expect(details_amd).to_not eq([])
      header = details_amd.shift
      expect(header[0]).to eq("Date")
    end
  end

  describe "Get historical data with invalid data" do
    details = scraper.lookup_historical_data(:symbol => "POOP")
    it "POOP should return nil" do
      expect(details).to eq(nil)
    end
  end

end
