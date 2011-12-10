class ServicesController < ApplicationController
  
  caches_page :show
  
  before_filter :get_random_testimonial

  def show
    render :action => params[:service].gsub('-', '_')
  end
  
  protected
  
    def get_random_testimonial
      @testimonial = Testimonial.random_approved
    end
  
end
