if ENV['RAILS_ENV'] == 'production'
  ExceptionNotifier.exception_recipients = %w(bill@billeisenhauer.com)
  ExceptionNotifier.sender_address = "support@suzannecan.com"
  ExceptionNotifier.email_prefix = "[suzannecan.com] "
end