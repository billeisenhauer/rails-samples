class TagSubscriptionsExporter
  include UtilitySetup
  
  def self.work
    SiteStatistics.logger = logger
    SiteStatistics.collect_and_notify
  end
  
end