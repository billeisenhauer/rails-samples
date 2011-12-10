class SiteStatistics < ActiveRecord::Base
  
  cattr_accessor :logger
  
  ### ASSOCIATIONS ###
  
  belongs_to :site
  
  ### VALIDATIONS ###
  
  validates_presence_of     :site
  validates_presence_of     :collected_on
  validates_uniqueness_of   :collected_on,    :scope => :site_id
  validates_numericality_of :active_assets,   :greater_than_or_equal_to => 0
  validates_numericality_of :archived_assets, :greater_than_or_equal_to => 0
  validates_numericality_of :tagged_assets,   :greater_than_or_equal_to => 0
  
  ### ATTRIBUTES ###
  
  def name
    site && site.ancestry_names || 'Unknown Site'
  end
  
  ### FINDERS / NAMED SCOPES ###
  
  named_scope :for_date, lambda { |date| 
    {
      :joins => 'inner join sites on sites.id = site_statistics.site_id',
      :conditions => ['collected_on = ?', date],
      :order => 'sites.ancestry_names',
      :include => [:site]
    }
  }
  
  ### MANAGE ###
  
  def self.collect_and_notify(site=Site.roots.first, date=Date.today)
    logger.info "Collecting statistics for #{date.to_s(:us)}"
    collect(site, date)
    notify(date)
  end
  
  ### DELIVERY ###
  
  def self.notify(date=Date.today)
    SiteStatisticsMailer.deliver_statistics_notification(date, SiteStatistics.for_date(date))
  end
  
  ### COUNTS ###
  
  def self.collect(site=Site.roots.first, date=Date.today)
    active_assets   = InventoryAsset.active_assets_count(site, date)
    archived_assets = InventoryAsset.archived_assets_count(site, date)
    tagged_assets   = InventoryAsset.tagged_assets_count(site)
    update_or_create(site, date, active_assets, archived_assets, tagged_assets)
    site.children.each { |child_site| collect(child_site, date) }
    true
  end
  
  def self.update_or_create(site, date, active_assets, archived_assets, tagged_assets)
    stats = find_by_site_id_and_collected_on(site, date) || 
            new(:site => site, :collected_on => date)
    stats.active_assets   = active_assets
    stats.archived_assets = archived_assets
    stats.tagged_assets   = tagged_assets
    stats.save
  end
  
end
