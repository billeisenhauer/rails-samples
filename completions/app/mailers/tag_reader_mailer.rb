class TagReaderMailer < ApplicationMailer
  
  def unreported_notification(tag_reader)
    setup_email(tag_reader)
  end
  
  protected
  
    def setup_email(tag_reader)
      from_address  = AppConfig.from_address
      headers       "Reply-to" => from_address 
      @from         = from_address
      @recipients   = AppConfig.tag_reader_to_address
      @subject      = "#{AppConfig.app_name} - "
      @subject      += "STAGING - " if staging_environment?
      @subject      += "Unreporting Tag Reader"
      @sent_on      = Time.now
      @content_type = "text/html"
      @base_url     = "http://#{AppConfig.base_url}"
      @base_ssl_url = "https://#{AppConfig.base_url}"
      @body[:reader]  = tag_reader.reader
      @body[:address] = tag_reader.address || "[missing address]"
      @body[:last_reported_at] = tag_reader.last_reported_at
      @body[:unreported_days_count]  = tag_reader.unreported_days_count
      
    end

end