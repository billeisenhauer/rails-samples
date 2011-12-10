class ContactsController < ApplicationController
  
  # GET /contact
  def show
    @contact = Contact.new
  end

  # POST /contact
  def create
    @contact = Contact.new(params[:contact])
    @contact.save!
    flash[:notice] = "Thanks!  Your message has been received."
    redirect_to root_path
  rescue ActiveRecord::RecordInvalid
    render :action => 'show'
  end
  
end
