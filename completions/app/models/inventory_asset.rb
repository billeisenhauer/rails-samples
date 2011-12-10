require 'fastercsv'

class InventoryAsset < ActiveRecord::Base
  
  STATES = %w(red yellow green blue)
  
  HUMANIZED_COLUMNS = {
    :actual_delivery_on => "Actual Delivery Date",
    :additional_amount => "Additional Amount",
    :client_name => 'Client',
    :cos => 'CoS',
    :days_lead_time => 'Lead Time (Days)',
    :engineering_amount => 'Engineering Amount',
    :expected_delivery_on => 'Expected Delivery Date',
    :fo => 'Field Order',
    :fo_on => "FO Date",
    :gr_on => "GR Date",
    :installed_on => "Install Date",
    :ocs_g => 'OCS-G',
    :ordered_on => "Order Date",
    :part_number => 'Part #',
    :pe => 'PE',
    :po_number => "SWPS PO #",
    :quantity_ordered => 'Qty Ordered',
    :quantity_received => 'Qty Received',
    :quantity_installed => 'Qty Installed',
    :quantity_on_location => "Qty on Location",
    :rfq_number => 'RFQ',
    :serial_number => 'Serial Number',
    :shipping_amount => 'Shipping Amount',
    :state => 'Flag',
    :sub_category => 'Sub Category',
    :tag_id => 'Tag',
    :total_cost_amount => 'Total Cost Amount',
    :total_sales_amount => 'Total Sales Amount',
    :tr_assignment => 'TR Assignment',
    :tr_on => 'TR Date',
    :tr_status => 'TR Status',
    :unit_cost_amount => 'Unit (cost)',
    :unit_sales_amount => 'Unit (sales)',
    :measurement_unit => 'Unit of Measurement'
  }
  
  cattr_accessor :logger
  attr_accessor  :delete_attachment
  
  ### CALLBACKS ###
  
  before_validation :set_gr_state
  before_validation :set_state
  before_save       :set_amount_totals
  before_save       :reset_notification_recipients
  after_save        :send_flag_change_notification,
                    :if => Proc.new { |asset| asset.state_change? }
  after_save        :send_movement_notification,
                    :if => Proc.new { |asset| asset.location_change? }
  
  ### ASSOCIATIONS ###
  
  belongs_to :pe,               :class_name => 'User', :foreign_key => 'pe_id' 
  belongs_to :tr_assignment,    :class_name => 'User', :foreign_key => 'tr_assignment_id'
  belongs_to :site
  belongs_to :tag
  belongs_to :category
  belongs_to :parent_asset_lot, :class_name => 'InventoryAsset', :foreign_key => 'parent_asset_id'
  has_many   :sold_asset_lots,  :class_name => 'InventoryAsset', :foreign_key => 'parent_asset_id'
  
  has_attached_file :attachment,
                    :url  => "/inventory_assets/attachments/:id/:basename.:extension",
                    :path => ':rails_root/attachments/:class/:id/:basename.:extension'
  
  ### AUDITING ###
  
  EXCLUDED_ATTRIBUTES_FROM_AUDIT = [
    :id, 
    :created_at, 
    :updated_at, 
    :recipients, 
    :parent_asset_id,
    :last_seen_location,
    :last_seen_at
  ]
  
  acts_as_audited :except => EXCLUDED_ATTRIBUTES_FROM_AUDIT
  
  ### VALIDATIONS ###
  
  validates_inclusion_of :state,        :in => STATES
  validates_presence_of  :po_number,    :if => :red?
  validates_presence_of  :ordered_on,   :if => :red?
  validates_presence_of  :gr,           :if => :yellow?
  validates_presence_of  :gr_on,        :if => :yellow?
  validates_presence_of  :fo,           :if => :green?
  validates_presence_of  :fo_on,        :if => :green?
  validates_presence_of  :installed_on, :if => :blue?    
  
  validates_numericality_of :unit_cost_amount,   :allow_nil => true, :greater_than_or_equal_to => 0
  validates_numericality_of :engineering_amount, :allow_nil => true, :greater_than_or_equal_to => 0
  validates_numericality_of :additional_amount,  :allow_nil => true, :greater_than_or_equal_to => 0
  validates_numericality_of :shipping_amount,    :allow_nil => true, :greater_than_or_equal_to => 0
  validates_numericality_of :total_cost_amount,  :allow_nil => true, :greater_than_or_equal_to => 0
  validates_numericality_of :unit_sales_amount,  :allow_nil => true, :greater_than_or_equal_to => 0
  validates_numericality_of :total_sales_amount, :allow_nil => true, :greater_than_or_equal_to => 0
  validates_numericality_of :cos,                :allow_nil => true, 
                            :greater_than_or_equal_to => 0,
                            :only_integer => true

  validates_presence_of     :site
  validates_uniqueness_of   :tag_id, :message => 'is already assigned',
                            :allow_nil => true
  validates_attachment_size :attachment, :less_than => 4.megabytes
  
  ### FINDERS / NAMED SCOPES ###

  named_scope :only_at_site, lambda { |filter_site|
    { :conditions => ['inventory_assets.site_id = ?', filter_site] }
  }
  named_scope :for_site, lambda { |filter_site|
    if filter_site
      { :conditions => ['inventory_assets.id in (?)', filter_site.all_inventory_assets] } 
    else
      # No site passed in should return no assets.
      { :conditions => '1 = 2' }
    end
  }
  named_scope :for_state, lambda { |state|
    if state
      { :conditions => ['inventory_assets.state = ?', state] } 
    else
      {}
    end
  }
  named_scope :sorted_by, lambda { |sort_options|
    field, direction = sort_options.split(' ')
    asset = InventoryAsset.new
    options = case field
      when 'tag_number'
        { :order => "lower(tags.tag_number) #{direction}" }
      when 'category'
        { :order => "lower(categories.name) #{direction}" }
      when 'pe'
        { :order => "lower(users.name) #{direction}" }
      when 'tr_assignment'
        { :order => "lower(tr_assignments_inventory_assets.name) #{direction}" }
      else
        if asset.column_for_attribute(field).number? || field_is_date?(field)
          { :order => "#{field} #{direction}" }  
        else
          { :order => "lower(inventory_assets.#{field}) #{direction}" }  
        end
    end
    options.merge(:include => [:tag, :category, :pe, :tr_assignment])
  }
  
  named_scope :untagged, :conditions => 'tag_id IS NULL'
  named_scope :tagged,   :conditions => 'tag_id IS NOT NULL'
  named_scope :since,  lambda { |*args| {:conditions => ["installed_on IS NULL or installed_on >= ?", (args.first || 2.months.ago)]} }
  named_scope :older,  lambda { |*args| {:conditions => ["installed_on IS NOT NULL and installed_on < ?", (args.first || 2.months.ago)]} }
  
  named_scope :peuser_name_like, lambda { |*args| 
    {
    :joins => 'left join users pe_users on pe_users.id = inventory_assets.pe_id',
    :conditions => ['pe_users.name like ?', "%#{args.first}%"]
    }
  }
  named_scope :tr_name_like, lambda { |*args| 
    {
    :joins => 'left join users tr_users on tr_users.id = inventory_assets.tr_assignment_id',
    :conditions => ['tr_users.name like ?', "%#{args.first}%"]
    }
  }
  named_scope :cat_name_like, lambda { |*args| 
    {
    :joins => 'left join categories cats on cats.id = inventory_assets.category_id',
    :conditions => ['cats.ancestry_names like ?', "%#{args.first}%"]
    }
  }
  
  def self.unseen(hours=4)
    hours_ago = hours.hours.ago
    joins = [
      'inner join tags on inventory_assets.tag_id = tags.id',
      'inner join tag_readings on tags.last_tag_reading_id = tag_readings.id',
      'inner join tag_readers on tag_readings.tag_reader_id = tag_readers.id'
    ]
    conditions = [
      'tag_readings.updated_at < ?',
      'tag_readers.last_reported_at > tag_readings.updated_at'
    ]
    params = [hours.hours.ago]
    find(
      :all, 
      :joins => joins.join(' '),
      :conditions => conditions.join(' and ').to_a + params,
      :readonly => false
    )
  end
  
  def self.active_assets_count(site, date)
    only_at_site(site).since(date - 2.months).count
  end
  
  def self.archived_assets_count(site, date)
    only_at_site(site).older(date - 2.months).count
  end
  
  def self.tagged_assets_count(site)
    only_at_site(site).tagged.count
  end
  
  ### SEARCHING / SORTING / FILTERING ###
  
  def self.filter(list_options={:sorted_by => 'description'})
    ar_proxy = InventoryAsset
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
    excluded_columns = %w(recipients)
    string_columns   = %w(peuser_name_like cat_name_like tr_name_like)
    (columns - excluded_columns).each do |column|
      if column.type == :string && !excluded_columns.include?(column.name)
        string_columns << column.name 
      end
    end
    method_name = string_columns.join('_or_') + '_like'
    send(method_name, query)
  end
  
  ### ATTRIBUTES ###
  
  def days_lead_time
    read_attribute(:days_lead_time) || 0
  end
  
  def state_change?
    self.changes.keys.include?('state')
  end
  
  def location_change?
    self.changes.keys.include?('last_seen_location')
  end
  
  def last_seen_location
    read_attribute(:last_seen_location) || 'OUT'
  end
  
  def category_name
    category ? category.ancestry_names : 'Uncategorized'
  end
  
  def site_name
    site ? site.name : ''
  end
  
  def pe_name
    pe ? pe.display_name : 'None'
  end
  
  def tr_assignment_name
    tr_assignment ? tr_assignment.display_name : 'None'
  end
  
  def tag_number
    tag ? tag.tag_number : 'Untagged'
  end
  alias :tag_name :tag_number
  
  def last_seen_at(user=nil)
    seen = read_attribute(:last_seen_at)
    seen ? seen.in_time_zone.to_s(:us_with_time) : 'Never'
  end
  
  def gr_value
    gr ? 'YES' : 'NO'
  end
  
  def tr_status_value
    if tr_status.nil?
      'Unreviewed' 
    else
      tr_status ? 'PASS' : 'FAIL'
    end
  end
  
  def ordered_on_value
    dt = read_attribute(:ordered_on)
    dt ? dt.to_s(:mmddyy) : ''
  end
  
  def expected_delivery_on_value
    dt = read_attribute(:expected_delivery_on)
    dt ? dt.to_s(:mmddyy) : ''
  end
  
  def actual_delivery_on_value
    dt = read_attribute(:actual_delivery_on)
    dt ? dt.to_s(:mmddyy) : ''
  end
  
  def gr_on_value
    dt = read_attribute(:gr_on)
    dt ? dt.to_s(:mmddyy) : ''
  end
  
  def tr_on_value
    dt = read_attribute(:tr_on)
    dt ? dt.to_s(:mmddyy) : ''
  end
  
  def fo_on_value
    dt = read_attribute(:fo_on)
    dt ? dt.to_s(:mmddyy) : ''
  end
  
  def installed_on_value
    dt = read_attribute(:installed_on)
    dt ? dt.to_s(:mmddyy) : ''
  end
  
  def delivery_on_value
    dt = read_attribute(:delivery_on)
    dt ? dt.to_s(:mmddyy) : ''
  end
  
  def quantity_ordered 
    read_attribute(:quantity_ordered) || 0
  end
  
  def quantity_installed
    read_attribute(:quantity_installed) || 0
  end
  
  def quantity_on_location
    read_attribute(:quantity_on_location) || 0
  end
  
  ### INVENTORY STATUS ###
  
  def unseen_days_count
    tag && tag.unseen_days_count || 0
  end
  
  def out!
    logger.info "Checking out: #{po_number}"
    update_attributes(:last_seen_location => nil)
  end
  
  def self.checkout_unseen_assets
    unseen_assets = unseen
    unseen_assets.each { |asset| asset.out! }
    logger.info "Checked out #{unseen_assets.count} inventory assets"
  end
  
  def splittable?
    return false if serial_number?
    return false unless received?
    original_lot? && available_qty_on_location?
  end
  
  ### SPLIT SUPPORT ###
  
  CLONEABLE_ATTRIBUTES = %w(
    rfq_number vendor po_number ordered_on days_lead_time
    expected_delivery_on category_id part_number description 
    quantity_ordered unit_cost_amount engineering_amount 
    additional_amount shipping_amount site_id
  )
  
  def self.split_from(inventory_asset)
    split_attributes_array = inventory_asset.attributes.select do |k,v| 
      CLONEABLE_ATTRIBUTES.include?(k) 
    end.flatten
    a = new(Hash[*split_attributes_array])
    a.parent_asset_id = inventory_asset.id
    a
  end
  
  def split_lot?
    !! (parent_asset_lot || parent_asset_id)
  end
  
  def original_lot?
    !split_lot?
  end
  
  def split!
    InventoryAsset.transaction do 
      self.quantity_on_location += quantity_installed
      save!
      if parent_asset_lot
        quantity_on_location = parent_asset_lot.quantity_on_location - quantity_installed
        quantity_installed   = parent_asset_lot.quantity_installed + quantity_installed
        parent_asset_lot.update_attributes!(
          :quantity_on_location => quantity_on_location,
          :quantity_installed => quantity_installed
        )
      end
    end
  end
  
  ### IMPORT / EXPORT ###
  
  EXPORTABLE_ATTRIBUTES = %w(
    site state pe client_name project ocs_g field well rfq_number vendor po_number
    ordered_on days_lead_time expected_delivery_on category part_number
    description quantity_ordered quantity_received quantity_installed
    quantity_on_location measurement_unit serial_number tag last_seen_location
    last_seen_at unit_cost_amount engineering_amount additional_amount
    shipping_amount total_cost_amount unit_sales_amount total_sales_amount
    cos actual_delivery_on gr gr_on tr_on tr_assignment tr_status fo fo_on
    installed_on bill_and_hold delivery_on notes
  )
  
  def self.import(data)
    parser = FasterCSV.new(data, :headers => true)
    attribute_mappings = csv_header_mapping
    parser.header_convert { |field| attribute_mappings[field] }
    parser.convert do |field, info|
      case info.header
        when 'site'
          Site.find_by_name(field)
        when 'pe', 'tr_assignment'
          User.find_by_name(field)
        when 'category'
          Category.find_by_ancestry_names(field)
        when 'tag'
          Tag.find_by_tag_number(field)
        when 'tr_status'
          if field.upcase == 'PASS'
            true
          elsif field.upcase == 'FAIL'
            false
          else
            nil
          end
        when 'gr'
          field == 'YES'
        when /^(.)+_on$/
          begin
            date_delimiter = field.include?('/') && '/'
            date_delimiter ||= field.include?('-') && '-'
            year = field.split(date_delimiter).last
            year_pattern = year.length == 2 ? '%y' : '%Y'
            Date.strptime(field, "%m/%d/#{year_pattern}") 
          rescue 
            nil
          end
        else
          field
      end
    end
    imported_count = rejected_count = 0
    parser.each do |row| 
      begin
        logger.info row.to_hash
        attributes = row.to_hash
        attributes.delete_if { |key, value| !attribute_mappings.values.include?(key) } 
        inventory_asset = InventoryAsset.create(attributes)
        imported_count += 1 unless inventory_asset.new_record?
        if inventory_asset.new_record?
          logger.debug "Problem with row:\n#{attributes}\n#{inventory_asset.errors.full_messages}"
          rejected_count += 1
        end
      rescue Exception => e
        logger.debug "Problem with row (exception):\n"
        row.to_hash.each { |key, value| logger.debug "#{key} => #{value}" }
        logger.debug e.message
        rejected_count += 1
      end
    end
    [imported_count, rejected_count]
  end
  
  def self.csv_header_mapping
    result = {}
    EXPORTABLE_ATTRIBUTES.each do |attribute|
      result[human_attribute_name(attribute)] = attribute
    end
    result
  end
  
  def self.export(list_options)
    FasterCSV.generate do |csv|
      csv << csv_header
      InventoryAsset.filter(list_options).each { |a| csv << to_csv_row(a) }
    end
  end
  
  def self.csv_header
    result = []
    EXPORTABLE_ATTRIBUTES.each do |attribute|
      result << human_attribute_name(attribute)
    end
    result
  end
  
  def self.to_csv_row(inventory_asset)
    result = []
    EXPORTABLE_ATTRIBUTES.each do |attribute|
      case attribute
        when 'pe', 'category', 'tr_assignment', 'tag', 'site'
          value = inventory_asset.send("#{attribute}_name")
        when /^(.)+_on$/, 'tr_status', 'gr'
          value = inventory_asset.send("#{attribute}_value")
        else
          value = inventory_asset.send(attribute)
      end
      value = value.strip if value.is_a?(String)
      value = nil if value.is_a?(String) && value.empty?
      result << value
    end
    result
  end
  
  def downloadable_by?(user)
    !user.guest?
  end
  
  ### MISCELLANEOUS ###
  
  def self.content_column_names
    content_columns.map(&:name)
  end
  
  protected
    
    ### STATE MANAGEMENT ###

    def calculate_state
      return 'blue'   if installable? && installed?
      return 'green'  if sellable? && sold?
      return 'yellow' if received?
      'red'
    end
      
    def installable?
      sold? && received?
    end  
    
    def sold?
      !! (fo && fo_on)
    end
    
    def ordered?
      !! (po_number && ordered_on)
    end
    
    def installed?
      !! installed_on
    end
    
    def sellable?
      received?
    end
    
    def received?
      !! (gr && gr_on)
    end
    
    ### MISCELLANEOUS ###
    
    def set_state
      self.state = calculate_state
    end
    
    def set_gr_state
      self.gr = !!gr_on
      true
    end
    
    def set_amount_totals
      self.total_cost_amount  = calculate_total_cost_amount
      self.total_sales_amount = calculate_total_sales_amount
      self.cos = calculate_cos
      true
    end
    
    def calculate_cos
      total_sales_amount > 0 ? total_cost_amount / total_sales_amount * 100 : 0
    end
    
    def calculate_total_cost_amount
      total = 0 
      total += ((unit_cost_amount || 0) * quantity_ordered)
      total += (engineering_amount || 0)
      total += (additional_amount || 0)
      total += (shipping_amount || 0)
      total
    end
    
    def calculate_total_sales_amount
      ((unit_sales_amount || 0) * quantity_ordered)
    end
  
    def red?
      state == 'red'
    end
  
    def yellow?
      state == 'yellow'
    end
  
    def green?
      state == 'green'
    end
  
    def blue?
      state == 'blue'
    end
    
    def available_qty_on_location?
      return false unless quantity_on_location
      quantity_on_location.to_i > 1
    rescue ArgumentError
      false
    end
    
    def serial_number?
      serial_number && serial_number.strip.any?
    end
    
    def self.field_is_date?(field)
      %w(fo_on gr_on ordered_on installed_on tr_on expected_delivery_on actual_delivery_on).include?(field)
    end
    
    def reset_notification_recipients
      self.recipients = NotificationSpecification.recipients_for(self)
    end
    
    def send_flag_change_notification
      if recipients.any?
        InventoryAssetMailer.deliver_flag_change_notification(self)
      end
    end
    
    def send_movement_notification
      if recipients.any?
        InventoryAssetMailer.deliver_movement_notification(self)
      end
    end
    
    def self.human_attribute_name(attribute)
      HUMANIZED_COLUMNS[attribute.to_sym] || super
    end
    
    ### ATTACHMENT HANDLING ###
    
    def delete_attachment?
      delete_attachment == '1'
    end
    
    before_validation :clear_attachment

    def clear_attachment
      self.attachment = nil if delete_attachment? && !attachment.dirty?
      self.delete_attachment = '0'
    end
    
end
