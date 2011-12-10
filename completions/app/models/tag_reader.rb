class TagReader < ActiveRecord::Base
  
  cattr_accessor :logger
  
  ### ASSOCIATIONS ###
  
  belongs_to :site
  
  ### CALLBACKS ###
  
  before_validation :set_address
  
  ### VALIDATIONS ###
  
  validates_presence_of     :site
  
  validates_presence_of     :reader
  validates_uniqueness_of   :reader
  
  validates_presence_of     :latitude,           :unless => :address?
  validates_numericality_of :latitude,           :unless => :address?
  validate                  :validate_latidude,  :unless => :address?
  validates_presence_of     :longitude,          :unless => :address?
  validates_numericality_of :longitude,          :unless => :address?
  validate                  :validate_longitude, :unless => :address?
  
  validates_presence_of     :address
  
  ### FINDERS / NAMED SCOPES ###
  
  named_scope :for_site, lambda { |filter_site|
    if filter_site
      { :conditions => ['tag_readers.id in (?)', filter_site.all_tag_readers] } 
    else
      {}
    end
  }
  named_scope :sorted_by, lambda { |sort_options|
    field, direction = sort_options.split(' ')
    options = case field
      when 'site'
        { :order => "lower(sites.name) #{direction}" }
      else
        { :order => "lower(tag_readers.#{field}) #{direction}" }
    end
    options.merge(:include => [:site])
  }
  named_scope :unreported, lambda { |*args| {:conditions => ["last_reported_at IS NOT NULL and last_reported_at < ?", (args.first || 1.day.ago)]} }
  
  
  ### SEARCHING / SORTING / FILTERING ###
  
  def self.filter(list_options={:sorted_by => 'reader'})
    ar_proxy = TagReader
    if list_options.is_a?(Hash)
      list_options.each do |key, value|
        next unless list_option_names.include?(key) 
        next if value.blank? 
        ar_proxy = ar_proxy.send(key, value)
      end
    end
    ar_proxy
  end

  def self.list_option_names
    self.scopes.map{|s| s.first} + [:search]
  end
  
  def self.search(query)
    string_columns = []
    columns.each do |column|
      string_columns << column.name if column.type == :string
    end
    method_name = string_columns.join('_or_') + '_like'
    send(method_name, query)
  end
  
  ### NOTIFICATION ###
  
  def self.notify_for_unreporting_tag_readers
    unreported_readers = unreported
    unreported_readers.each { |reader| TagReaderMailer.deliver_unreported_notification(reader) }
    logger.info "Failed to read #{unreported_readers.count} tag readers"
  end
  
  def unreported_days_count
    (DateTime.now.to_date - last_reported_at.to_date).to_i
  end
  
  ### MISCELLANEOUS ###
  
  def site_name
    site ? site.name : 'No site'
  end  
  
  def address?
    address
  end
  
  def mapped?
    !!(latitude && longitude)
  end
  
  protected
  
    def validate_latidude
      return unless latitude
      if latitude < -90 || latitude > 90
        self.errors.add(:latitude, 'is invalid, try -90 to 90')
      end
    end
  
    def validate_longitude
      return unless longitude
      if longitude < -180 || longitude > 180
        self.errors.add(:longitude, 'is invalid, try -180 to 180')
      end      
    end
    
    def set_address
      self.address = ReverseGeocoder::Multi.geocode(latitude, longitude)[:address] if mapped?
    end
  
end
