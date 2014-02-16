require 'spec_helper'
require 'schwab_parser'

describe SchwabParser do
  parser = SchwabParser.new(DebugLogger.modes[:debug])
  subject {parser}

  csv = "Transactions  for account nv_default XXXX-4245 as of 07/28/2013 02:11:18 ET,,,,,,,\n"\
        "Date,Action,Quantity,Symbol,Description,Price,Amount,Fees & Comm\n"\
        "11/2/12,Buy,24,XLF,SECTOR SPDR FINCL SELECTSHARES OF BENEFICIAL INT,$16.20 ,($397.75),$8.95\n"\
        "3/8/12,,, ,\"Tfr JPMORGAN CHASE BAN, CARL-ERIK SVENSS type: MONEYLINK TRANSFER\",,\"($10,771.61)\",\n" \
        "03/16/2012 as of 03/15/2012,,, ,BANK INT 021612-031512 type: bank interest,,$0.01 ,\n"\
        "7/2/13,Dividend,,IYW,ISHARES TRUST TECHNOLOGYETF type: ORD DIV - CASH,,$5.19 ,\n"\
        "5/28/13,,,ARMH,ARM HOLDINGS PLC ADR   F1 ADR REP 3 ORD type: ADR MGMT FEE,,($0.35),\n"
 
 csv_2_15 =  "\"Transactions  for account nv_default XXXX-4245 as of 02/15/2014 21:29:55 ET\"\n"\
             "\"Date\",\"Action\",\"Symbol\",\"Description\",\"Quantity\",\"Price\",\"Fees & Comm\",\"Amount\",\n"\
             "\"10/15/2013\",\"ADR Mgmt Fee\",\"ARMH\",\"ARM HOLDINGS PLC ADR F1 ADR REP 3 ORD\",\"\",\"\",\"\",\"-$0.52\",\n"\
             "\"10/15/2013\",\"Qualified Dividend\",\"ARMH\",\"ARM HOLDINGS PLC ADR F1 ADR REP 3 ORD\",\"\",\"\",\"\",\"$4.35\",\n"\
             "\"09/30/2013\",\"Cash Dividend\",\"RYU\",\"GUGGENHEIM ETF S&P 500 EQUAL WEIGHT UTILITIES\",\"\",\"\",\"\",\"$8.51\",\n"\
             "\"09/10/2013\",\"Sell                \",\"SCHH\",\"SCH US REIT ETF\",\"118\",\"$30.631\",\"$0.06\",\"$3614.40\",\n"\
             "\"05/13/2013\",\"Buy                 \",\"ARMH\",\"ARM HOLDINGS PLC ADR F1 ADR REP 3 ORD\",\"20\",\"$49.37\",\"$8.95\",\"-$996.35\",\n"


  describe "Can do conversions" do
    num_tests = ["$20,000.00 ", "8.50", "$8.95", "1,000.56", "($418.09)", "($4,180.09)"]
    num_answers = [20000.00, 8.50, 8.95, 1000.56, -418.09, -4180.09]
    csv_l = CSV.parse(csv)
    csv_l.slice!(0) # First entry is garbage
    headers = csv_l.slice!(0)

    it "converts numbers" do
      num_tests.each_index do |test|
        expect(parser.convert_dollar_amount(num_tests[test])).to eq(num_answers[test])
      end
    end

    fee_answers = [8.95, 0.0, 0.0, 0.0, 0.35]
    fee_pos = 7
    it "converts fees" do
      csv_c = csv_l.clone
      csv_c.each_index do |test|
        # action parser will determine if this is a fee or not
        action = parser.parse_action(csv_c[test])
        fees = parser.parse_fees(csv_c[test], action)
        expect(fees).to eq(fee_answers[test])
      end
    end

    action_answers = ["Buy", nil, nil, "Dividend", "Fee"]
    action_pos = 1
    it "converts actions" do
      csv_c = csv_l.clone
      csv_c.each_index do |test|
        action = parser.parse_action(csv_c[test])
        expect(action).to eq(action_answers[test])
      end
    end

    date_answers = [Date.new(2012,11,2), Date.new(2012,3,8), Date.new(2012,3,16),
                    Date.new(2013,7,2), Date.new(2013,5,28)]
    date_pos = 0
    it "converts dates" do
      csv_c = csv_l.clone
      csv_c.each_index do |test|
        date = parser.parse_date(csv_c[test][date_pos])
        expect(date).to eq(date_answers[test])
      end
    end
  end

  describe "Can parse old CSV format" do
    it "parses" do
      transactions = parser.parse(csv)
      expect(transactions.size).to eq(5)
    end
  end

  describe "Can parse 2.15.2014 CSV format" do
    it "parses" do
      transactions = parser.parse(csv_2_15)
      expect(transactions.size).to eq(5)
      expect(transactions[0][:Date]).to eq(Date.new(2013,10,15))
      expect(transactions[4][:Fees]).to eq(8.95)
      expect(transactions[4][:Amount]).to eq(-996.35)
    end
  end

end
