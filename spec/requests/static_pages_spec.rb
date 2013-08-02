require 'spec_helper'

describe "StaticPages" do
  # Makes "it" the page object in the tests below
  subject {page}

  # Begin tests for home page
  # This is named purely for readability
  describe "Home page" do

    # Tests following the vefore statement apply to the root_path page
    before {visit root_path}

    # Equivalent, but old test
    #it "should have the content 'Shiny'" do
    #  expect(page).to have_content('Shiny')
    #end
    it { should have_content('Shiny') }
    it { should  have_title('Shiny') }
  end

  describe "Help page" do
    before {visit help_path}
    it { should have_content('Help') }
    it { should have_title('Help') }
  end

  describe "About page" do
    before {visit about_path}
    it { should have_content('About') }
    it { should have_title('About') }
  end
end
