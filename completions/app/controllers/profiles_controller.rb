class ProfilesController < ApplicationController
  
  before_filter :require_user
  filter_access_to [:edit, :update], :attribute_check => false
  
  ### UPDATE ###
  
  def update
    current_user.update_attributes!(params[:user])
    flash[:notice] = "Successfully updated profile."
    redirect_to edit_profile_path
  rescue ActiveRecord::RecordInvalid
    render :action => 'edit'
  end
  
end
