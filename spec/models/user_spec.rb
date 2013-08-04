require 'spec_helper'

describe User do
  before{ @user = User.new(name: "Tester Rodriguez", email: "test@er.com", password: "foobar", password_confirmation: "foobar") }

  subject {@user}

  it {should respond_to(:name)}
  it {should respond_to(:email)}
  it {should respond_to(:password_digest)}
  it {should respond_to(:password)}
  it {should respond_to(:password_confirmation)}
  it {should respond_to(:authenticate)}
  it {should be_valid}

  # The following does not work.  It seems to modify the user used above
  #before { @user.name = " " }
  #it {should_not be_valid(:name)}

  describe "when name is not present" do
    before {@user.name=" "}
    it {should_not be_valid}
  end
  
  describe "when email is not present" do
    before { @user.email = " " }
    it {should_not be_valid}
  end

  describe "when name is too long" do
    before {@user.name = "a" * 51}
    it {should_not be_valid}
  end

  describe "when an e-mail address is invalid" do
    it "should be invalid" do
      addresses = %w[user@foo,com user_at_foo.org user.one@foo. foo@user_under.com foo@b+e.org dbl@dots..com]
      addresses.each do |addr|
        @user.email = addr
	expect(@user).not_to be_valid
      end
    end
  end

  describe "when an e-mail address is valid" do
    it "should be valid" do
      addresses = %w[user@foo.com A_US-ER@f.b.org first.last@japan.jp a+b@gmail.com]
      addresses.each do |addr|
        @user.email = addr
	expect(@user).to be_valid
      end
    end
  end

  describe "when an e-mail is already registers" do
    before do
      dup_user = @user.dup
      dup_user.email = @user.email.upcase
      dup_user.save
    end

    it {should_not be_valid}
  end

  describe "when password is not present" do
    before do
      @user = User.new(name: "Tester Rodriguez", email: "test@er.com", password: " ", password_confirmation: " ")
    end
    it {should_not be_valid}
  end

  describe "when password doesn't match confirmation" do
    before {@user.password_confirmation = "mismatch"}
    it {should_not be_valid}
  end

	describe "return value of authenticate method" do
		before {@user.save}
		let(:found_user) {User.find_by(email: @user.email)}

		describe "with valid password" do
			it {should eq found_user.authenticate(@user.password)}
		end

		describe "with invalid password" do
			let (:user_inval) {found_user.authenticate("invalid!") }
			it {should_not eq user_inval}
			specify { expect(user_inval).to be_false }
		end
	end

	describe "with a password that is too short" do
		before { @user.password = @user.password_confirmation = "a" * 5 }
		it {should_not be_valid}
	end

	describe "with a password that is too long" do
		before { @user.password = @user.password_confirmation = "a" * 51 }
		it {should_not be_valid}
	end
end
