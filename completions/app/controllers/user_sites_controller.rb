class UserSitesController < ApplicationController
  
  before_filter :require_user
  filter_access_to [:edit, :update], :attribute_check => false
  
  def update
    current_user.update_attributes!(params[:user])
    flash[:notice] = "Site has been changed."
    redirect_to root_path
  rescue ActiveRecord::RecordInvalid
    render :action => 'edit'
  end
  
end
