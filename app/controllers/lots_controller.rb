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
    @lot = Lot.new
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

    logger.debug ("selected: #{params[:sel_t]}")
    if defined? @selected_transactions and @selected_transactions
      logger.debug("appending...")
      @selected_transactions.append(params[:sel_t])
    else
      logger.debug("replacing...")
      @selected_transactions = [params[:sel_t]]
    end

    # Convert selected transactions to integers
    @selected_transactions = @selected_transactions.map{|id| id.to_i}

  end

  # POST /lots
  # POST /lots.json
  def create
    @lot = Lot.new(lot_params)

    respond_to do |format|
      if @lot.save
        flash.now[:success] = "Created new Lot #{@lot.id}"
        format.html { redirect_to lots_edit_path }
      else
        flash.now[:error] = "Failed to create Lot.  Please try again later."
        format.html { render action: 'new' }
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
    if lot_id == "new"
      @lot = Lot.create(user_id: current_user.id)
    else
      @lot = Lot.find(lot_id) if lot_id != nil
    end

    if (lot_id = nil or @lot == nil)
      flash[:error] = "Invalid lot selection.  Please make sure you select one lot and at least one transaction."
      # The below assignment does not persist... TODO: Pass list of selected transactions back to edit
      @selected_transactions = transaction_ids
      redirect_to lots_edit_path
      return
    end

    # Create a list of transactions
    transactions = Transaction.find(transaction_ids)

    if @lot.add_transactions(transactions) and @lot.save
      flash[:success] = "Successfully added #{transactions.count} #{'transaction'.pluralize(transactions.count)} to Lot #{@lot.id}"
      redirect_to lots_edit_path
      return
    else
      flash[:error] = ""
      if @lot.errors.any?
        @lot.errors.full_messages.each do |message|
          flash[:error] += "#{message}  "
        end
      else
        flash[:error] = "Unknown error"
      end
      redirect_to lots_edit_path
      return
    end
  end

  # DELETE /lots/1
  # DELETE /lots/1.json
  def destroy
    # Find all the associated transactions, and set their lots to nil
    Transaction.find_all_by_lot_id(@lot.id).each do |trans|
      trans.lot = nil
      trans.save
    end

    @lot.destroy

    flash.now[:success] = "Deleted Lot #{@lot.id}"
    redirect_to lots_edit_path
    return
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
