require 'spec_helper'

describe Testimonial do
  before(:each) do
    @valid_attributes = {
      
    }
  end

  it "should create a new instance given valid attributes" do
    Testimonial.create!(@valid_attributes)
  end
end
