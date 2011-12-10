class UnseenAssetNotifier
  include UtilitySetup
  
  # Run once a day to fetch the assets that haven't been seen in more than four
  # hours to send notifications.
  #
  def self.work
    InventoryAsset.logger = logger
    InventoryAsset.checkout_unseen_assets
  end
  
end