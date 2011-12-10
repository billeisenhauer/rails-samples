require 'spec_helper'

TAG_READINGS_XML =<<-XML
<?xml version="1.0"?>
<TagEvents>
  <TagEvent Timestamp="20091210194038" Event="TagFound">
  	<Reader>
  		<ID>07261M0628.2.1.1</ID>
  		<Type>GateReader</Type>
  	</Reader>
  	<Tag>
  		<ID>0.200.173.464</ID>
  		<BatteryPercent>101</BatteryPercent>
  	</Tag>
  </TagEvent>
  <TagEvent Timestamp="20091210194039" Event="TagFound">
  	<Reader>
  		<ID>07261M0628.2.1.2</ID>
  		<Type>GateReader</Type>
  	</Reader>
  	<Tag>
  		<ID>0.200.173.465</ID>
  		<BatteryPercent>101</BatteryPercent>
  	</Tag>
  </TagEvent>
<TagEvents>
XML

BAD_TAG_READINGS_XML =<<-XML
<?xml version="1.0"?>
<TagEvents>
  <TagEvent Timestamp="X" Event="TagFound">
  	<Reader>
  		<ID>07261M0628.2.1.1</ID>
  		<Type>GateReader</Type>
  	</Reader>
  	<Tag>
  		<ID>0.200.173.464</ID>
  		<BatteryPercent>101</BatteryPercent>
  	</Tag>
  </TagEvent>
  <TagEvent Timestamp="20091210194039" Event="TagFound">
  	<Reader>
  		<ID>07261M0628.2.1.2</ID>
  		<Type>GateReader</Type>
  	</Reader>
  	<Tag>
  		<ID>0.200.173.465</ID>
  		<BatteryPercent>101</BatteryPercent>
  	</Tag>
  </TagEvent>
<TagEvents>
XML

describe TagReading do
  
  before(:each) do
    @site = Factory.create(:site)
    @tag_1 = Factory.create(:tag, :site => @site, :tag_number => '0.200.173.464')
    @tag_2 = Factory.create(:tag, :site => @site, :tag_number => '0.200.173.465')
    @tag_reader_1 = Factory.create(:tag_reader, :site => @site, :reader => '07261M0628.2.1.1')
    @tag_reader_2 = Factory.create(:tag_reader, :site => @site, :reader => '07261M0628.2.1.2')
  end
  
  ### VALIDATIONS ###
  
  it "is valid with valid attributes" do
    TagReading.new(:tag => @tag_1, :tag_reader => @tag_reader_1).should be_valid
  end

  it "should be invalid without tag" do
    tag_reading = TagReading.new(:tag_reader => @tag_reader_1)
    tag_reading.should_not be_valid
    tag_reading.should have(1).error_on(:tag)
  end
  
  it "should be invalid without tag reader" do
    tag_reading = TagReading.new(:tag => @tag_1)
    tag_reading.should_not be_valid
    tag_reading.should have(1).error_on(:tag_reader)
  end  
  
  it "should update tag" do
    updated_at = 20.seconds.ago
    TagReading.create!(:tag => @tag_1, :tag_reader => @tag_reader_1, :updated_at => updated_at)
    @tag_1.last_reported_at.should eql(updated_at)
    @tag_1.last_location.should eql(@tag_reader_1.address)
  end
  
  it "should update tag reader" do
    updated_at = 20.seconds.ago
    TagReading.create!(:tag => @tag_1, :tag_reader => @tag_reader_1, :updated_at => updated_at)
    @tag_reader_1.last_reported_at.should eql(updated_at)
  end
  
  ### PROXY HANDLING ###
  
  it "should use proxy when configured" do
    AppConfig.should_receive(:proxy_host).exactly(3).times.and_return('http://localhost')
    AppConfig.should_receive(:proxy_port).twice.and_return(8080)
    TagReading.should_receive(:http_proxy).with('http://localhost', 8080)
    load File.join(RAILS_ROOT, 'app', 'models', 'tag_reading.rb')
  end
  
  ### IMPORT ###
  
  it "should import readings" do
    response = HTTParty::Response.new(TAG_READINGS_XML, TAG_READINGS_XML, '200', 'OK')
    TagReading.should_receive(:get).and_return(response)
    lambda do
      TagReading.import    
    end.should change{ TagReading.count }.by(2)
    tag_readings = TagReading.latest
    tag_readings[0].tag_reader_id.should eql(@tag_reader_1.id)
    tag_readings[0].tag_id.should eql(@tag_1.id)
    tag_readings[0].updated_at.should eql(DateTime.parse('20091210194038'))
    tag_readings[1].tag_reader_id.should eql(@tag_reader_2.id)
    tag_readings[1].tag_id.should eql(@tag_2.id)
    tag_readings[1].updated_at.should eql(DateTime.parse('20091210194039'))
  end
  
  it "should import readings, but skip bad ones" do
    response = HTTParty::Response.new(BAD_TAG_READINGS_XML, BAD_TAG_READINGS_XML, '200', 'OK')
    TagReading.should_receive(:get).and_return(response)
    lambda do
      TagReading.import    
    end.should change{ TagReading.count }.by(1)
    tag_reading = TagReading.latest.first
    tag_reading.tag_reader_id.should eql(@tag_reader_2.id)
    tag_reading.tag_id.should eql(@tag_2.id)
    tag_reading.updated_at.should eql(DateTime.parse('20091210194039'))
  end
  
  it "should import no readings for bad response" do
    response = HTTParty::Response.new('', '', '503', 'Server Error')
    TagReading.should_receive(:get).and_return(response)
    lambda do
      TagReading.import    
    end.should change{ TagReading.count }.by(0)
  end
  
  ### MISCELLANEOUS ###
  
  it "should update stale tags and tag_readers" do
    updated_at = DateTime.now
    stale_tag        = Factory.create(:tag, :site => @site, :tag_number => '0.200.173.466', :last_reported_at => 1.day.ago)
    stale_tag_reader = Factory.create(:tag_reader, :site => @site, :reader => '07261M0628.2.1.3', :last_reported_at => 1.day.ago)
    tag_reading      = TagReading.create!(:tag => stale_tag, :tag_reader => stale_tag_reader, :updated_at => updated_at)
    stale_tag.reload.last_reported_at.to_s.should == tag_reading.updated_at.to_s
    stale_tag_reader.reload.last_reported_at.to_s.should == tag_reading.updated_at.to_s
  end
  
end
