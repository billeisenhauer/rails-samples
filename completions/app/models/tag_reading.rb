class TagReading < ActiveRecord::Base
  include HTTParty
  
  base_uri "#{AppConfig.comms_url}/data/rfid"
  
  if AppConfig.proxy_host && AppConfig.proxy_host.strip.any?
    http_proxy AppConfig.proxy_host, AppConfig.proxy_port && AppConfig.proxy_port.to_i || 80
  end
  
  cattr_accessor :logger
  
  ### CALLBACKS ###
  
  after_save :update_last_reported
  
  ### ASSOCIATIONS ###
  
  belongs_to :tag
  belongs_to :tag_reader
  
  ### VALIDATIONS ###
  
  validates_presence_of :tag
  validates_presence_of :tag_reader
  
  def self.import(options={})
    xml = acquire(options)
    readings = parse(xml)
    create_readings(readings)
  end
  
  def self.latest
    sql =<<-SQL
      select tr1.*
        from tag_readings as tr1
       where tr1.id = (select id 
                        from tag_readings as tr2 
                       where tr2.tag_id = tr1.tag_id 
                       order by tr2.updated_at desc limit 1)
    SQL
    find_by_sql(sql)
  end
  
  protected
  
    def update_last_reported
      tag_reader.update_attributes(:last_reported_at => updated_at) if stale_tag_reader?
      if stale_tag?
        tag.last_tag_reading_id = self.id
        tag.last_reported_at    = updated_at
        tag.last_location       = tag_reader.address
        tag.save(false)
      end
    end
    
    def stale_tag?
      return true unless tag.last_reported_at
      updated_at > tag.last_reported_at
    end
    
    def stale_tag_reader?
      return true unless tag_reader.last_reported_at
      updated_at > tag_reader.last_reported_at
    end
  
    ### COMMS INTEGRATION ###
  
    def self.acquire(options={})
      query = {:minutes => 30}.merge(options)
      response = get("/recent_tagreads", :query => query)
      if response.code.to_i != 200
        logger.error "Gateway error: #{response.code}"
        ''
      else
        response
      end
    end
    
    def self.parse(xml)
      readings = []
      doc = Hpricot.XML(xml)
      (doc/'//TagEvents/TagEvent' ).each do |tag_event|
        begin
          reader = tag_event/'//Reader'
          tag = tag_event/'//Tag'
          next unless reader && tag
          updated_at = DateTime.parse(tag_event['Timestamp'])
          reader_number = (reader/'ID').inner_html
          tag_number = (tag/'ID').inner_html
          readings << Struct.new(:updated_at, :reader, :tag_number).new(updated_at, reader_number, tag_number)
        rescue ArgumentError => e
          logger.error "Parsing error: #{e.message}"
          next
        end
      end
      readings
    end
    
    def self.create_readings(readings)
      count = 0
      tags, readers = {}, {}
      readings.each do |reading|
        tag = find_tag(tags, reading)
        reader = find_reader(readers, reading)
        next unless tag && reader  
        count += 1
        logger.info "Creating reading for #{tag.id} at #{reading.updated_at}"
        TagReading.create(
          :updated_at => reading.updated_at,
          :tag_id => tag.id,
          :tag_reader_id => reader.id
        )
      end
      logger.info "Creating #{count} tag readings"
    end
    
    def self.find_tag(tags, reading)
      tag = tags[reading.tag_number]
      unless tag 
        tag = tags[reading.tag_number] = Tag.find_by_tag_number(reading.tag_number)
      end
      tag
    end
    
    def self.find_reader(readers, reading)
      reader = readers[reading.reader]
      unless reader 
        reader = readers[reading.reader] = TagReader.find_by_reader(reading.reader)
      end
      reader
    end
  
end
