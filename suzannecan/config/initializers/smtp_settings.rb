if ENV['RAILS_ENV'] == 'production'
  ActionMailer::Base.smtp_settings = {
    :address => "smtp.gmail.com",
    :port => 587,
    :domain => "suzannecan.com",
    :user_name => AppConfig.reply_from,
    :password => AppConfig.from_password,
    :authentication => :plain,
    :tls => true
  }
end