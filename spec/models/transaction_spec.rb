require 'spec_helper'

describe Transaction do
  before {@transaction = FactoryGirl.create(:buy_ge)}

  it {should respond_to(:user)}
  it {should respond_to(:price)}
  it {should respond_to(:amount)}
  it {should respond_to(:date)}
  it {should respond_to(:quantity)}
  it {should respond_to(:symbol)}
  it {should respond_to(:fees)}
  it {should respond_to(:action)}
end
