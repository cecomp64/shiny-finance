require 'spec_helper'

describe Lot do
  before do
    @user = FactoryGirl.create(:user_with_lots)
    @lot = @user.lots[0]

    # Output some information about what we generated for debug
    @lot.transactions.each do |trans|
      puts "#{trans.action.name} #{trans.quantity} @ #{trans.price} for Lot #{trans.lot_id} with t.id #{trans.id}"
    end
  end

  subject {@lot}

  it {should respond_to(:transactions)}
  it {should respond_to(:quantity_remaining)}
  it {should be_valid}

  describe "when there are more sells than buys" do
    # Add an extra sale onto the default, even lot that is generated up top
    before {@lot.transactions.append(FactoryGirl.create(:sell_ge, user: @lot.user))}
    it {should_not be_valid}
  end

  describe "when there are more than one symbol" do
    # Buy a different stock (nvda vs. ge), and add it to this lot
    before {@lot.transactions.append(FactoryGirl.create(:buy_nvda, user: @lot.user))}
    it {should_not be_valid}
  end
end
