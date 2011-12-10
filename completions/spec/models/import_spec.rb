require 'spec_helper'

describe Import do
  
  before(:each) do
    @csv_file = File.new(File.expand_path("../files/tmp/valid.csv", File.dirname(__FILE__)), 'r')
    @valid_attributes = { :csv => @csv_file }
  end

  it "should create a new instance given valid attributes" do
    Import.create!(@valid_attributes)
  end
  
  it "should be invalid without csv file" do
    import = Import.new
    import.should_not be_valid
    import.should have(1).error_on(:csv)
  end
  
  it "should be invalid with invalid csv file" do
    invalid_csv = File.expand_path("../files/tmp/invalid.doc", File.dirname(__FILE__))
    import = Import.new(:csv => invalid_csv)
    import.should_not be_valid
    import.should have(1).error_on(:csv)
  end
  
  it "should process import file" do
    InventoryAsset.should_receive(:import).and_return([5, 10])
    import = Import.create!(@valid_attributes)
    import.imported_rows.should be_equal(5)
    import.rejected_rows.should be_equal(10)
  end
  
  it "should humanize attributes" do
    Import.human_attribute_name('csv').should eql("CSV file")
  end
  
end
