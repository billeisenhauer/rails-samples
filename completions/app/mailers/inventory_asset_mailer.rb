class InventoryAssetMailer < ApplicationMailer
  
  def flag_change_notification(inventory_asset)
    setup_email(inventory_asset)
    setup_flag_change_fields(inventory_asset)
  end
  
  def movement_notification(inventory_asset)
    setup_email(inventory_asset)
    setup_movement_fields(inventory_asset)
  end
  
  def unseen_notification(inventory_asset)
    setup_email(inventory_asset)
    setup_unseen_fields(inventory_asset)
  end
  
  protected
  
    def setup_email(inventory_asset)
      from_address  = AppConfig.from_address
      headers       "Reply-to" => from_address 
      @from         = from_address
      @recipients   = inventory_asset.recipients
      @subject      = "#{AppConfig.app_name} - "
      @subject      += "STAGING - " if staging_environment?
      @sent_on      = Time.now
      @content_type = "text/html"
      @base_url     = "http://#{AppConfig.base_url}"
      @base_ssl_url = "https://#{AppConfig.base_url}"
      @body[:inventory_asset] = inventory_asset
      @body[:serial_number]   = inventory_asset.serial_number || "[missing serial number]"
      @body[:po_number]       = inventory_asset.po_number || "[missing PO number]"
      @body[:part_number]     = inventory_asset.part_number || "[missing part number]"
      @body[:project]         = inventory_asset.project || "[missing project]"
      @body[:description]     = inventory_asset.description || "[no description]"
    end
    
    def setup_flag_change_fields(inventory_asset)
      @subject += "Flag Change Alert"
      @body[:state]         = inventory_asset.state.upcase      
    end
    
    def setup_movement_fields(inventory_asset)
      @subject += "Movement Alert"
      @body[:last_seen_location] = inventory_asset.last_seen_location
    end
    
    def setup_unseen_fields(inventory_asset)
      @subject += "Unseen Alert"
      @body[:unseen_days_count]  = inventory_asset.unseen_days_count
      @body[:last_seen_location] = inventory_asset.last_seen_location
    end
  
end