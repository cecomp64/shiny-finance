module SessionsHelper
  # Signs in a given user by creating a new remember token cookie,
  # and storing that remember token in the User model.  The token
  # is encrypted to prevent fraudulent access
	def sign_in(user)
		remember_token = User.new_remember_token
		cookies[:remember_token] = {value: remember_token, expires: 1.day.from_now.utc}
		user.update_attribute(:remember_token, User.encrypt(remember_token))
		self.current_user = user
	end

  # Convenience function for setting the current user
	def current_user=(user)
		@current_user = user
	end

  # Convenience function for getting the current user.  Do so
  # by looking up a user by the stored remember token cookie
	def current_user
		remember_token = User.encrypt(cookies[:remember_token])
		@current_user ||= User.find_by(remember_token: remember_token)
	end

  # Check if a user is signed in by trying to get the current_user
	def signed_in?
		!current_user.nil?
	end

  # Sign out by setting the current user to nil, and deleting
  # the remember token cookie
	def sign_out
		self.current_user = nil
		cookies.delete(:remember_token)
	end

end
