ActionController::Routing::Routes.draw do |map|
  
  ### SIGNIN ###
  map.signout '/signout', :controller => 'user_sessions', :action => 'destroy'
  map.signin  '/signin',  :controller => 'user_sessions', :action => 'new'
  map.resource :user_sessions

  ### DOWNLOADS ###

  map.download '/inventory_assets/attachments/:id/:basename.:format', 
               :controller => 'inventory_assets', :action => 'download', 
               :conditions => { :method => :get }

  ### RESOURCES ###
  map.resources :users, 
                :collection => { :bulk => :put }
  map.resources :tags, 
                :collection => { :edit_import => :get, :bulk => :put, :import => :put }
  map.resources :tag_readers,
                :collection => { :bulk => :put }
  map.resources :sites,
                :collection => { :bulk => :put }
  map.resources :notifications,
                :collection => { :bulk => :put }
  map.resources :categories,
                :collection => { :bulk => :put }
  map.changesite '/change-site',  :controller => 'user_sites', :action => 'edit'
  map.resource   :user_sites
  map.resource   :profile
  
  ### INVENTORY ASSETS ###
  map.resources :inventory_assets, 
                :has_many => :revisions,
                :collection => { 
                  :sample_import => :get,
                  :new_import => :get,
                  :import => :put,
                  :export => :get,
                  :bulk => :put, 
                  :per_page => :put 
                },
                :member => { :new_split => :get, :create_split => :post }

  ### ROOT PATH ###
  map.root :controller => "root", :action => 'index'
  
  ### ERRORS ###
  map.unauthorized '/unauthorized',
    :controller => "errors", :action => 'unauthorized'
  map.site_membership_required '/site_membership_required', 
    :controller => "errors", :action => 'site_membership_required'
  map.errors '*args', :controller => "errors", :action => "notfound"
end
