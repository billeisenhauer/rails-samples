case @environment
  when 'production'
    
    every 1.hour, :at => [5, 35] do
      runner "TagReadingsImporter.run" 
    end

    every 4.hours, :at => 10 do
      runner "UnseenAssetNotifier.run"
    end
    
    every 1.day, :at => '12:30 am' do
      runner "UnseenTagReaderNotifier.run"
    end

    every 1.day, :at => '12:30 am' do
      runner "TagSubscriptionsExporter.run"
      rake "dump:create"
    end
    
  when 'staging'
    every 1.hour, :at => [5, 35] do
      runner "TagReadingsImporter.run" 
    end

    every 4.hours, :at => 10 do
      runner "UnseenAssetNotifier.run"
    end
    
    every 1.day, :at => '12:30 am' do
      runner "UnseenTagReaderNotifier.run"
    end
    
    every 1.day, :at => '12:30 am' do
      runner "TagSubscriptionsExporter.run"
      rake "dump:create ASSETS='public/inventory_assets/attachments/*'"
    end
end