class PagesController < ApplicationController
  
  caches_page :show
  
  before_filter :get_random_testimonial

  def show
    render :action => params[:page]
  end
  
  protected
  
    def get_random_testimonial
      @testimonial = Testimonial.random_approved
    end
  
end
