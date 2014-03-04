include ActionView::Helpers::TextHelper

class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :signed_in_user, only: [:edit, :update]

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
    # Get some sample transactions to display
    # For now just pick the first two sumbols
    # TODO: Build a list of favorites
    # TODO: Call analyze for these... move analyze to a common location
    #symbols = Transaction.select(:symbol).where(user_id: 14).distinct.limit(2)
    @transactions = current_user.transactions.limit(5)
  end

  # GET /users/new
  def new
    @user = User.new # This is passed into the view for form_for
  end

  # GET /users/1/edit
  def edit
		@user = User.find(params[:id])
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
				sign_in @user
        format.html { redirect_to @user }
        format.json { render action: 'show', status: :created, location: @user }
				flash[:success] = "Welcome to Shiny Finance!"
      else
        format.html { render action: 'new' }
        format.json { render json: @user.errors, status: :unprocessable_entity }

				flash_errors
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user }
        format.json { head :no_content }
				flash[:success] = "Successfully updated your profile!"
      else
        format.html { render action: 'edit' }
        format.json { render json: @user.errors, status: :unprocessable_entity }

				flash_errors
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

		def flash_errors
		  flash[:error] = "You have " + pluralize(@user.errors.count, "error") + " with your submission:"
			@user.errors.full_messages.each do |msg|
				flash[:error] += "  " + msg + "."
			end
		end

		def signed_in_user
			redirect_to signin_url, notice: "Please sign in." unless signed_in?
		end
end
