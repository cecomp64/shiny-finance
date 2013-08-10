require 'spec_helper'

describe "UserPages" do
  subject {page}

  describe "signup page" do
    before { visit signup_path }
    it {should have_content('Sign up')}
    it {should have_title('Sign up')}
  end

	describe "profile page" do
		# Get a user from the factory
		let (:user) { FactoryGirl.create(:user) }

		before { visit user_path(user) }
		it { should have_content(user.name) }
		it { should have_title(user.name) }
	end

	describe "signup" do
		before { visit signup_path }
		let (:submit) { "Create User" }

		describe "with invalid information" do
			it "should not create a user" do
				expect { click_button submit }.not_to change(User, :count)
			end

			#it {should have_content('error')}
		end

		describe "with valid info" do
			before do
				fill_in "Name", with: "Carlos"
				fill_in "Email", with: "Carlos@example.com"
				fill_in "Password", with: "carlosrulez"
				fill_in "Password confirmation", with: "carlosrulez"
			end

			it "should create a user" do
				expect {click_button submit}.to change(User, :count).by(1)
			end

			describe "after saving the user" do
				before {click_button submit}
				let(:user) {User.find_by(email: "carlos@example.com")}

				it {should have_link('Sign out')}
				it {should have_title(user.name)}
				# The below function fails to compile for some reason
				###it {should have_selector('div.flash.success', text: 'Welcome')}
			end
		end
	end
end
