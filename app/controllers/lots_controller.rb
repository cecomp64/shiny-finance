class LotsController < ApplicationController
  before_action :set_lot, only: [:show, :destroy]
  before_action :signed_in_user, only: [:show, :edit, :update, :destroy, :index, :delete_all]

  # GET /lots
  # GET /lots.json
  def index
    @lots = Lot.find_all_by_user_id(current_user.id)
    if not @lots
      flash.now[:error] = "No lots found for this user!"
    end
  end

  # GET /lots/1
  # GET /lots/1.json
  def show
  end

  # GET /lots/new
  def new
    @lot = lot.new
  end

  # GET /lots/edit
  # Lot editing is special, because we want to show all lots side by side
  # with all transactions for easy grouping.  Because of this, edit
  # operates on an undefined lot until submission.
  def edit
    # Select all buys and sells by default
    @transactions = current_user.transactions.where("action_id=#{Action.find_by_name('buy').id} OR action_id=#{Action.find_by_name('sell').id}")
    @lots = current_user.lots
    @select_lots = true
  end

  # GET /import
  def import
  end

  # POST /lots
  # POST /lots.json
  def create
    @lot = Lot.new(lot_params)

    respond_to do |format|
      if @lot.save
        format.html { redirect_to @lot }
        format.json { render action: 'show', status: :created, location: @lot }
      else
        format.html { render action: 'new' }
        format.json { render json: @lot.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /lots/update
  def update
    # We should get a list of transactions
    transaction_ids = params[:transactions]
    if not transaction_ids
      flash[:error] = "No transactions selected.  Please select some transactions to add to a lot."
      redirect_to lots_edit_path
      return
    end

    # ... and a lot id
    lot_id = params[:lot_id]
    @lot = Lot.find(lot_id) if lot_id != nil
    if (lot_id = nil or @lot == nil)
      flash[:error] = "Invalid lot selection.  Please make sure you select one lot and at least one transaction."
      redirect_to lots_edit_path
      return
    end

    # Create a list of transactions
    transactions = Transaction.find(transaction_ids)

    # If we're all good... update and save
    @lot.transactions += transactions
    if @lot.save
      flash[:success] = "Successfully added #{transactions.count} #{'transaction'.pluralize(transactions.count)} to Lot #{@lot.id}"
      redirect_to lots_edit_path
    end
  end

  # DELETE /lots/1
  # DELETE /lots/1.json
  def destroy
    @lot.destroy
    respond_to do |format|
      format.html { redirect_to lots_url }
      format.json { head :no_content }
    end
  end

  # Delete all lots for the signed in user
  def delete_all
    my_lots = Lot.find_all_by_user_id(current_user.id)
    my_lots.each do |lots|
      lots.destroy
    end

    redirect_to lots_url
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_lot
      @lot = Lot.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def lot_params
      params.require(:lot).permit(:user_id)
    end

    # Check if the user is signed in.  If not, redirect to sign in page.
		def signed_in_user
			redirect_to signin_url, notice: "Please sign in." unless signed_in?
		end
end
