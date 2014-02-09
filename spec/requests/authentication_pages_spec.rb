require 'spec_helper'
require 'support/utilities'

describe "AuthenticationPages" do
	subject {page}

	describe "authorization" do
		let(:user) { FactoryGirl.create(:user) }
		before {sign_in(user) }
	end

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
	end # Signin

	describe "authorization" do
		describe "for non-signed in users" do
			let (:user) {FactoryGirl.create(:user)}

			describe "in the Users controller" do
				describe "visiting the edit page" do
					before {visit edit_user_path(user)}
					it {should have_title('Sign in')}
				end # edit page

				describe "submitting to the update action" do
				  # patch issues an udpate http request (patch)
					before {patch user_path(user)}
					specify {expect(response).to redirect_to(signin_path)}
				end
			end
		end
	end
end
