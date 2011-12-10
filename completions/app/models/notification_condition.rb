class NotificationCondition < ActiveRecord::Base
  
  OPERATORS = ['<', '>', '==', '!=']
  
  ### CALLBACKS ###
  
  before_validation :set_field_type
  
  ### ASSOCIATIONS ###
  
  belongs_to :notification_specification
  
  ### VALIDATIONS ###
  
  validates_presence_of  :field
  validates_inclusion_of :field, :in => InventoryAsset.content_column_names
  validates_presence_of  :field_type
  validates_presence_of  :operator
  validates_inclusion_of :operator, :in => OPERATORS
  validates_presence_of  :value
  validate               :ensure_value_compatible_with_field_type
  
  ### ATTRIBUTES ###
  
  attr_accessible :field, :operator, :value
  
  def native_value
    return nil unless value
    case field_type
      when 'integer'
        value.to_i
      when 'decimal'
        value.to_d
      when 'text'
        value
      when 'varchar(255)'
        value
      when 'datetime'
        DateTime.parse(value)
      when 'date'
        Date.parse(value)
      when 'boolean'
        value.downcase == 'true'
    end
  rescue ArgumentError
    nil
  end
  
  ### SPEC SUPPORT ###
  
  def satisfied_by?(inventory_asset)
    if operator != '!=' && inventory_asset.attributes[field]
      inventory_asset.attributes[field].send(operator.to_sym, native_value)
    else  
      inventory_asset.attributes[field] != native_value
    end
  end
  
  protected
  
    def set_field_type
      column = get_column_for_field
      return unless column
      self.field_type = column.sql_type
    end
    
    def get_column_for_field
      return unless field
      column = InventoryAsset.columns_hash[field]
    end
    
    def ensure_value_compatible_with_field_type
      return unless field_type
      unless value == native_value.to_s
        return if valid_decimal_field_value?
        return if valid_datetime_field_value?
        self.errors.add(:value, "is not a legal value")
      end
    end
    
    def valid_decimal_field_value?
      return false unless field_type == 'decimal'
      Float(value) == native_value.to_f
    rescue ArgumentError
      false
    end
    
    def valid_datetime_field_value?
      return false unless field_type == 'datetime'
      DateTime.parse(value) == native_value
    rescue ArgumentError
      false
    end
  
end
