class UserSessionsController < ApplicationController
  
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => :destroy
  
  layout 'signin'

  def new
    @user_session = UserSession.new
  end

  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      flash[:notice] = "Sign in successful!"
      redirect_back_or_default root_url
    else
      note_failed_signin
      render :action => :new
    end
  end

  def destroy
    current_user_session.destroy
    flash[:notice] = "Sign out successful!"
    redirect_back_or_default signin_url
  end
  
  protected
  
    # Track failed login attempts
    def note_failed_signin
      flash[:error] = "Couldn't sign you in as '#{params[:user_session][:username]}'"
      logger.warn "Failed login for '#{params[:user_session][:username]}' from" + 
                  " #{request.remote_ip} at #{Time.now.utc}"
    end
  
end
