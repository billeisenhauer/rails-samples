require 'spec_helper'

describe RootController do

  before(:each) do
    activate_authlogic
  end

  # it "should redirect to inventory assets path" do
  #   @current_user = Factory.create(:champion_user)
  #   login
  #   get :index
  #   response.should redirect_to(inventory_assets_path)
  # end
  
  # it "should redirect to sign in path" do
  #   logout
  #   get :index
  #   response.should redirect_to(signin_path)
  # end

end
