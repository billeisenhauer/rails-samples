# lib/tasks/populate.rake
namespace :db do
  desc "Erase and fill database"
  task :populate => :environment do
    require 'populator'
    require 'faker'
    
    def site_ids
      Site.all.map(&:id)
    end
    
    def random_site_id
      site_ids[rand(site_ids.size)]
    end
    
    # User.populate 100 do |user|
    #   user.username        = (Faker::Name.first_name.first + Faker::Name.last_name).downcase
    #   user.time_zone       = "Central Time (US & Canada)"
    #   user.login_count     = 0..300
    #   user.last_login_at   = 30.days.ago..Time.now
    #   user.last_request_at = 30.days.ago..Time.now
    #   # SiteMembership.populate(1) do |site_membership|
    #   #   site_membership.user_id = user.id
    #   #   site_membership.site_id = Site.all.map(&:id)
    #   # end
    # end
    
    # count = 0
    # Tag.populate 100 do |tag|
    #   count += 1
    #   tag.tag_number = "100.100.100.#{"%03d" % count}"
    #   tag.last_reported_at = 30.days.ago..Time.now
    #   tag.last_location = Faker::Address.street_address + 
    #                       Faker::Address.street_name + ', ' +
    #                       Faker::Address.city + ', ' +
    #                       Faker::Address.us_state
    #   tag.site_id = random_site_id
    # end
    
    # Ordered
    count = 0
    InventoryAsset.populate 500 do |asset|
      count += 1
      asset.site_id      = random_site_id
      asset.ordered_on   = 5.months.ago..Time.now
      asset.po_number    = "WE540#{"%03d" % count}"
      asset.vendor       = ['Rockbestos', 'Diamould, Ltd.', 'TPC', 'Grainger', 'All Hose']
      asset.quantity     = 1..8400
      asset.client_name  = ['BHP', 'Anadarko']
      asset.rfq_number   = "1234#{"%03d" % count}"
      asset.project      = ['Neptune', 'Drysdale', 'Shenzi', 'Nansen']
      asset.description  = Populator.words(5..10)
      asset.notes        = Populator.paragraphs(1..2)
      asset.pe           = ['Ronald Amaya', 'Garrett Skaggs', 'John David', 'Hari Dutt']
      asset.total_amount = 100000..2000000
      asset.state       = 'red'
      if count % 2 == 0
        asset.state       = 'yellow'
        asset.gr_on = (asset.ordered_on + 14)..(asset.ordered_on + 30)
        if count % 4 == 0        
          asset.state     = 'green'
          # asset.so_number = "987#{"%03d" % count}"
          asset.fo_on     = (asset.gr_on + 14)..(asset.gr_on + 30)
          if count % 3 == 0
            asset.state        = 'blue'
            asset.installed_on = (asset.fo_on + 14)..(asset.fo_on + 30)
          end
        end
      end
    end
    
  end
end