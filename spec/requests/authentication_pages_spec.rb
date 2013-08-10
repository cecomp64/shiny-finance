require 'spec_helper'

describe "AuthenticationPages" do
	subject {page}

	describe "signin page" do
		before{ visit signin_path }
		
		it {should have_content('Sign in')}
		it {should have_title('Sign in')}
	end

	describe "signin" do
		before {visit signin_path}

		describe "with invalid credentials" do
			before {click_button "Sign in"}

			it {should have_title('Sign in')}
			it {should have_content('Error')}

			describe "after visiting another page" do
				before {click_link "Home"}
				it {should_not have_content('Error')}
			end
		end

		describe "with valid credentials" do
			let(:user) {FactoryGirl.create(:user)}
			before do
				fill_in "Email", with: user.email.upcase
				fill_in "Password", with: user.password
				click_button "Sign in"
			end

			it {should have_title(user.name)}
			it {should have_link('Profile', href: user_path(user))}
			it {should have_link('Sign out', href: signout_path)}
			it {should_not have_link('Sign in', href: signin_path)}

			describe "then sign out" do
				before {click_link "Sign out"}
				it {should have_link('Sign In')}
			end

		end
	end
end
