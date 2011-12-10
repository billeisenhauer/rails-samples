ActionController::Routing::Routes.draw do |map|

  map.root  :controller => 'pages', :action => 'home'
  map.pages ':page', :controller => 'pages', :action => 'show', :page => /home|about|faq|rates|services/
  map.services '/services/:service', :controller => 'services', :action => 'show', :service => /decorating/

  map.resource :contact

  # Used to catch any routes that have not been mapped.  These are 404 errors.
  map.errors '*args', :controller => "errors", :action => "notfound"
end
