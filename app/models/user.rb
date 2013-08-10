class User < ActiveRecord::Base
  # Validations
  #   name is not empty, and length is <=50 characters
  #   email is not empty, has a valid format, and is unique
  validates :name, presence:true, length: {maximum: 50}
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.\w+)*\.[a-z]+\z/i
  validates :email, presence:true, format: { with: VALID_EMAIL_REGEX },
    uniqueness: {case_sensitive: false}
	validates :password, length: {minimum: 6, maximum: 50}

  # Lower case e-mail before save to enforce uniqueness
  before_save { self.email = email.downcase }
	before_create :create_remember_token

	# Add password and password_confirmation as virtual variables
	has_secure_password

	def User.new_remember_token
		SecureRandom.urlsafe_base64
	end

	def User.encrypt(token)
		Digest::SHA1.hexdigest(token.to_s)
	end

private
	def create_remember_token
		self.remember_token = User.encrypt(User.new_remember_token)
	end
end
