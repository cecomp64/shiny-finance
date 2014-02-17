require 'google_finance_scraper'

class TransactionsController < ApplicationController
  before_action :set_transaction, only: [:show, :edit, :update, :destroy]
  before_action :signed_in_user, only: [:show, :edit, :update, :destroy, :index, :import, :import_schwab_csv, :analyze]

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

  # This is the action for the import view.
  # It takes a file in [:upload] and converts it
  # to a set of transaction objects, and then saves
  # them all for the signed in user.
  def import_schwab_csv
    csv = params[:upload].read()

    if (csv)
      sp = SchwabParser.new
      transactions = sp.parse(csv)
  
      transactions.each do |trans|
        trans[:user_id] = current_user.id
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
  def analyze
    @transactions = []
    #if params[:symbol]
      # Compute one transactions
    #else
      # Find all Buy transactions
      # Might need to rename Transaction database fields to lowercase...
      #@transactions = Transaction.find_all_by_Action("Buy", {:conditions => "WHERE user_id = #{current_user.id}"})
      @transactions = Transaction.find_by_sql("SELECT * FROM transactions WHERE user_id = #{current_user.id} AND action like 'Buy%' LIMIT 20")
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

  # TODO: Need to look for sales of this stock, and correlate that with
  # a specified lot.  Maybe default to selling oldest shares, and allow
  # user to assign lot numbers to transactions.  Maybe create a resource
  # to keep track of any given lot
  def analyze_transaction(trans)
    logger.debug "Original transaction: #{trans}\n\n"
    analyze = {}
    analyze[:action] = trans[:action]
    analyze[:symbol] = trans[:symbol]
    analyze[:price] = trans[:price]
    analyze[:quantity] = trans[:quantity]
    analyze[:cost] = (trans[:price] * trans[:quantity]) + trans[:fees]

    current_info = @stock_source.lookup_by_symbol(trans[:symbol])
    current_price = 0.0
    logger.debug "Lookup of #{trans[:symbol]}: #{current_info}\n\n"

    if (current_info) 
      current_price = current_info["price"]
    else
      flash[:error] = "Could not find price for #{trans[:symbol]}"
    end

    analyze[:currentPrice] = current_price
    # TODO: How do you compute dividends for any given lot?
    analyze[:dividendEarnings] = 0.0
    analyze[:totalEarned] = analyze[:currentPrice] * trans[:quantity]
    analyze[:return] = (analyze[:totalEarned] - analyze[:cost]) / analyze[:cost]
    logger.debug "Analyze transaction: #{analyze}\n\n"
    return analyze
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_transaction
      @transaction = Transaction.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def transaction_params
      params.require(:transaction).permit(:date, :action, :quantity, :symbol, :description, :price, :amount, :fees, :user_id)
    end

    # Check if the user is signed in.  If not, redirect to sign in page.
		def signed_in_user
			redirect_to signin_url, notice: "Please sign in." unless signed_in?
		end
end
