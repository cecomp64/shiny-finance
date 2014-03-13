require 'google_finance_scraper'

class TransactionsController < ApplicationController
  before_action :set_transaction, only: [:show, :edit, :update, :destroy]
  before_action :signed_in_user, only: [:show, :edit, :update, :destroy, :index, :import, :import_schwab_csv, :analyze, :delete_all]
  #before_validate :sanitize_params

  # GET /transactions
  # GET /transactions.json
  def index
    @transactions = Transaction.find_all_by_user_id(current_user.id)
    if not @transactions
      flash.now[:error] = "No transactions found for this user!"
    end
  end

  # GET /transactions/1
  # GET /transactions/1.json
  def show
  end

  # GET /transactions/new
  def new
    @transaction = Transaction.new
  end

  # GET /transactions/1/edit
  def edit
  end

  # GET /import
  def import
  end

  # GET /export
  # Return all transactions as a CSV
  def export
    @transactions = Transaction.find_all_by_user_id(current_user.id)
    csv = ""
    i = 0
    @transactions.each do |trans|
      if (i==0)
        csv += trans.to_csv(true)
      else
        csv += trans.to_csv(false)
      end
      i += 1
    end

    respond_to do |format|
      format.csv { send_data csv }
    end
  end

  # POST /transactions
  # POST /transactions.json
  def create
    @transaction = Transaction.new(transaction_params)

    respond_to do |format|
      if @transaction.save
        format.html { redirect_to @transaction }
        format.json { render action: 'show', status: :created, location: @transaction }
      else
        format.html { render action: 'new' }
        format.json { render json: @transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /transactions/1
  # PATCH/PUT /transactions/1.json
  def update
    respond_to do |format|
      if @transaction.update(transaction_params)
        format.html { redirect_to @transaction }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /transactions/1
  # DELETE /transactions/1.json
  def destroy
    @transaction.destroy
    respond_to do |format|
      format.html { redirect_to transactions_url }
      format.json { head :no_content }
    end
  end

  # Delete all transactions for the signed in user
  def delete_all
    my_trans = Transaction.find_all_by_user_id(current_user.id)
    my_trans.each do |trans|
      trans.destroy
    end

    redirect_to transactions_url
  end

  # This is the action for the import view.
  # It takes a file in [:upload] and converts it
  # to a set of transaction objects, and then saves
  # them all for the signed in user.
  def import_schwab_csv
    csv = params[:upload].read()

    if (csv)
      sp = SchwabParser.new
      trans_data = sp.parse(csv)
      
      # Create a hash of action names and ids
      actions = Action.all

      trans_data.each do |trans|
        trans[:user_id] = current_user.id
        trans[:action] = nil

        # Convert action description to action object
        actions.each do |a|
          if trans[:act] != nil and trans[:act].match(/#{a.name.singularize}/i)
            trans[:action] = a
          else
            logger.debug "Transaction Parameters: #{trans}\n"
          end
        end

        # Remove the act entry, otherwise Ruby will be confused
        trans.delete(:act)
        trans[:symbol] = trans[:symbol].upcase.strip

        t = Transaction.new(trans)
        if not t.save
          flash[:warn] = "Could not save transaction #{trans.to_s}"
        end
      end

      flash[:success] = "Successfully imported transactions!"
      redirect_to transactions_url
    else
      flash[:error] = "Unable to read uploaded CSV file"
      render action: import
    end
  end

  # Analyze a subset or all transactions.  If no parameter is provided
  # Iterate over every Buy action for now.  Fix this to be a max of 30
  # transactions to avoid timeouts.  TODO: Make this smart
  def analyze_old
    @transactions = []
    #if params[:symbol]
      # Compute one transactions
    #else
      # Find all Buy transactions
      # Might need to rename Transaction database fields to lowercase...
      #@transactions = Transaction.find_all_by_Action("Buy", {:conditions => "WHERE user_id = #{current_user.id}"})
      #@transactions = Transaction.find_by_sql("SELECT * FROM transactions WHERE user_id = #{current_user.id} AND action like 'Buy%' LIMIT 20")
      @transactions = Transaction.joins(:user).joins(:action).where(actions: {name: "buy"}, transactions: {:user_id => current_user.id}).limit(20)
      #logger.debug("Printing transactions...")
      #logger.debug(@transactions)
    #end

    # Compute some extra data
    if @stock_source == nil
      @stock_source = GoogleFinanceScraper.new(DebugLogger.modes[:debug])
    end

    @analyze = []
    @transactions.each do |trans|
      @analyze.append(analyze_transaction(trans))
    end

  end

  def analyze
    full_analysis
  end

  # TODO: Need to look for sales of this stock, and correlate that with
  # a specified lot.  Maybe default to selling oldest shares, and allow
  # user to assign lot numbers to transactions.  Maybe create a resource
  # to keep track of any given lot
  def analyze_transaction(trans)
    logger.debug "Original transaction: #{trans}\n\n"
    analyze = {}

    if (trans.action != nil)
      analyze[:action] = trans.action.name.capitalize
    else
      analyze[:action] = "--"
    end

    analyze[:symbol] = trans.symbol
    analyze[:price] = trans.price
    analyze[:quantity] = trans.quantity
    analyze[:cost] = (trans.price * trans.quantity) + trans.fees

    current_info = @stock_source.lookup_by_symbol(trans.symbol)
    current_price = 0.0
    logger.debug "Lookup of #{trans.symbol}: #{current_info}\n\n"

    if (current_info != nil) 
      current_price = current_info["price"]
    else
      flash[:error] = "Could not find price for #{trans.symbol}"
    end

    analyze[:currentPrice] = current_price
    # TODO: How do you compute dividends for any given lot?
    analyze[:dividendEarnings] = 0.0
    analyze[:totalEarned] = analyze[:currentPrice] * trans.quantity
    analyze[:return] = (analyze[:totalEarned] - analyze[:cost]) / analyze[:cost]
    logger.debug "Analyze transaction: #{analyze}\n\n"
    return analyze
  end

  private
    # Staging analysis in tis private function for now

    def full_analysis
      # Grab a list of different symbols - 10 at a time
      symbol_records = Transaction.find_by_sql("SELECT DISTINCT symbol FROM transactions WHERE user_id = #{current_user.id}")
      @symbol_page = Kaminari.paginate_array(symbol_records).page(params[:page]).per(10)

      # Grab bulk data for these symbols
      all_symbols = @symbol_page.map {|record| record.symbol}
      y = YahooFinanceScraper.new
      stock_info = y.lookup_by_symbols(all_symbols)

      # Analyze each symbol
      @results = []
      @symbol_page.each_with_index do |record, i|
        if record.symbol == nil or record.symbol.strip.empty?
          next
        end
        @results.append stock_analysis(record.symbol, stock_info[i])
      end
    end

    # + Group by Symbol, group by lot, order by date
    # 
    # ++ ARMH - $30.00 ++
    # Date    Action    Price   Quantity    Lot   Realized Gain   Unrealized Gain   Fees
    # 5/5/14    Buy   $40.00    20      N   $0.00     $0.00 / 0%
    # 6/5/14    Sell    $50.00    10      N   $100, 25%   $100, 25%
    # Today   Summary   $30.00    10      N   $100, 25%   -$100, -25%
    # 
    # 7/5/14    Buy   $30.00    20      M   $0.00     $0.00
    # 8/5/14    Sell    $25.00    10      M   -$50.00     -$50.00
    # Today   Summary   $30.00    10      M   -$50.00     $0.00
    # 
    # 5/25/14   Dividends per share NumberSharesAtThisTime  -   $$, Yield%
    # 7/25/14   Dividends lump sum  1     -   $$
    # 
    # ARMH Summary
    # Total Realized Gains    Total Unrealized Gains
    # $$$, %        $$$, %
    def stock_analysis(symbol, current_info = nil)
      # Grab current price
      logger.debug "Looking up symbol #{symbol}\n"

      # Lookup stock info if we didn't already get it in batch
      if not current_info
        if @stock_source == nil
          @stock_source = GoogleFinanceScraper.new(DebugLogger.modes[:debug])
        end

        current_info = @stock_source.lookup_by_symbol(symbol)
      end

      # Get all transactions (group by lots when available)
      tran_records = Transaction.joins(:user).where(transactions: {:symbol => symbol, :user_id => current_user.id}).order("date")

      lots = []
      lots.append(tran_records)

      summary = {}
      summary[:totalRealizedDollar] = 0.00
      summary[:totalRealizedPercent] = 0.00
      summary[:totalUnrealizedDollar] = 0.00
      summary[:totalUnrealizedPercent] = 0.00

      # Compute the gains and losses for each "lot"
      lots.each do |lot|
        quantity = 0.0
        cost = 0.0

        lot.each do |tran|
          if (tran.action)
            if (tran.action.is_dividend? or tran.action.is_interest?)
              summary[:totalRealizedDollar] += tran.amount
            elsif (tran.action.is_sell?)
              summary[:totalRealizedDollar] += tran.amount
              quantity -= tran.quantity
            elsif (tran.action.is_buy?)
              quantity += tran.quantity
              # Buy amounts are negative
              cost += tran.amount.abs
            elsif (tran.action.is_fee?)
              cost += tran.amount.abs
            end
          end # if tran.action
        end
        summary[:totalUnrealizedDollar] = quantity * current_info["price"]
        summary[:totalCost] = 0-cost
        summary[:netValue] = summary[:totalUnrealizedDollar] + summary[:totalRealizedDollar] - cost
        summary[:percent] = summary[:netValue] / cost
      end

      result = {}
      result[:lots] = lots
      result[:summary] = summary
      result[:symbol] = symbol
      result[:currentPrice] = current_info["price"]
      result[:change_amt] = current_info["change_amt"]

      return result
    end


    # Use callbacks to share common setup or constraints between actions.
    def set_transaction
      @transaction = Transaction.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    # Also make sure parameters follow certain guidelines - like symbols always capitalized
    def transaction_params
      params[:transaction][:symbol] = params[:transaction][:symbol].upcase.strip
      params.require(:transaction).permit(:date, :action, :quantity, :symbol, :description, :price, :amount, :fees, :user_id, :action_id)
    end

    # Check if the user is signed in.  If not, redirect to sign in page.
		def signed_in_user
			redirect_to signin_url, notice: "Please sign in." unless signed_in?
		end

end
