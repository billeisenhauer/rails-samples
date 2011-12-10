class SiteStatisticsMailer < ApplicationMailer
  
  def statistics_notification(date, site_statistics)
    setup_email(date, site_statistics)
  end
  
  protected
  
    def setup_email(date,site_statistics)
      from_address  = AppConfig.from_address
      headers       "Reply-to" => from_address 
      @from         = from_address
      @recipients   = AppConfig.subscription_to_address
      @subject      = "#{AppConfig.app_name} - "
      @subject      += "STAGING - " if staging_environment?
      @subject      += "Subscriptions Update"
      @sent_on      = Time.now
      @content_type = "text/html"
      @base_url     = "http://#{AppConfig.base_url}"
      @base_ssl_url = "https://#{AppConfig.base_url}"
      @body[:date] = date
      @body[:site_statistics] = site_statistics
    end

end