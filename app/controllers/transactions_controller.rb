class TransactionsController < ApplicationController
  before_action :set_transaction, only: [:show, :edit, :update, :destroy]
  before_action :signed_in_user, only: [:show, :edit, :update, :destroy, :index]

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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_transaction
      @transaction = Transaction.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def transaction_params
      params.require(:transaction).permit(:Date, :Action, :Quantity, :Symbol, :Description, :Price, :Amount, :Fees, :user_id)
    end

		def signed_in_user
			redirect_to signin_url, notice: "Please sign in." unless signed_in?
		end
end
