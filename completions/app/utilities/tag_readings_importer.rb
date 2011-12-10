class TagReadingsImporter
  include UtilitySetup
  
  # Fetch content from a server for all readers, parse the data, and save off 
  # readings.
  #
  # Runs twice and hour at :05 and :35.
  #
  def self.work
    TagReading.logger = logger
    TagReading.import
  end
  
end