class Import < ActiveRecord::Base
  
  HUMANIZED_COLUMNS = { :csv => "CSV file" }
  
  has_attached_file :csv
  
  ### CALLBACKS ###
  
  after_save :process_csv
  
  ### ATTRIBUTES ###
  
  attr_accessor :imported_rows, :rejected_rows
  
  ### VALIDATIONS ###
  
  validates_attachment_presence     :csv
  validates_attachment_content_type :csv, :content_type => [
    'text/comma-separated-values',
    'text/csv',
    'application/csv',
    'application/excel',
    'application/vnd.ms-excel',
    'application/vnd.msexcel',
    'text/anytext',
    'text/plain'
  ]
  validates_attachment_size         :csv, :less_than => 2.megabyte
  
  protected
  
    def self.human_attribute_name(attribute)
      HUMANIZED_COLUMNS[attribute.to_sym] || super
    end
  
    def process_csv
      self.imported_rows, self.rejected_rows = InventoryAsset.import(csv.to_file)
    end
  
end
