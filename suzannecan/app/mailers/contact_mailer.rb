class ContactMailer < ApplicationMailer

  # Acknowledge the message from the user.
  def acknowledge(contact)
    setup_email(contact)
    @recipients = contact.email
    @from       = AppConfig.reply_from
  end

  # Notify support personnel.
  def notify(contact)
    setup_email(contact)
    @recipients = AppConfig.send_to
    @from       = contact.email || AppConfig.reply_from
  end
  
  protected
  
    # All contact emails get these settings.
    def setup_email(contact)
      @sent_on        = Time.now
      @subject        = '[suzannecan.com] Message Received'
      @body[:contact] = contact
    end
  
end