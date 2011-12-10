class UnseenTagReaderNotifier
  include UtilitySetup
  
  # Run once a day to fetch the readers that haven't been seen in more than a
  # day to send notifications.
  #
  def self.work
    TagReader.logger = logger
    TagReader.notify_for_unreporting_tag_readers
  end
  
end