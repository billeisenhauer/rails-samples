class ContactObserver < ActiveRecord::Observer
  
  def after_create(contact)
    ContactMailer.deliver_acknowledge(contact)
    ContactMailer.deliver_notify(contact)
  rescue Exception => exception 
    STDERR.puts exception.message
  end  
  
end
