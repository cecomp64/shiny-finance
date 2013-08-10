class SessionsController < ApplicationController
	def new
	end

	def create
		user = User.find_by_email(params[:email].downcase)
		if (user && user.authenticate(params[:password]))
			# Sign in and redirecto to the user's show page
			flash[:success] = "You have successfully logged in as " + user.name + "."
			sign_in user
			redirect_to user
		else
			# use flash.now to post flash messages to rendered pages that are NOT new requests
			flash.now[:error] = "Invalid email or password"
			render 'new'
		end
	end

	def destroy
		sign_out
		flash[:success] = "You have been signed out."
		redirect_to root_url
	end
end
