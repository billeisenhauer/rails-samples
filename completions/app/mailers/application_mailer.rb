class ApplicationMailer < ActionMailer::Base
  self.template_root = File.join(RAILS_ROOT, 'app', 'mailers', 'views')
end