require_relative './spec_helper.rb'

describe "My Sinatra Application" do
  it "should allow accessing the home page" do
    get '/'
    # Rspec 2.x
    expect(last_response).to be_ok
  end

end
