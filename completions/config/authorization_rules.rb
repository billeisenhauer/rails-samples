authorization do
  
  role :guest do
    has_permission_on [:user_sites, :profiles], :to => :manage
    has_permission_on [:inventory_assets], :to => :read_only
  end
  
  role :champion do
    includes :guest
    has_permission_on [:revisions], :to => :read_only
    has_permission_on [:notifications], :to => :manage
    has_permission_on [:inventory_assets], :to => [:manage, :download]
  end
  
  role :administrator do
    includes :champion
    has_permission_on [:users, :sites, :categories, :revisions], :to => :manage
    has_permission_on [:tags], :to => :read_only
  end
  
  role :support_administrator do
    includes :administrator
    has_permission_on [:tags, :tag_readers], :to => :manage
  end
  
end

privileges do
  
  privilege :manage do
    includes :index, :list, :show, :new, :create, :edit, :update, :destroy, 
             :reload, :update_data, :bulk, :new_import, :import, :per_page,
             :new_split, :export, :sample_import
  end
      
  privilege :download do
    includes :download
  end
      
  privilege :read_only do
    includes :index, :show
  end    
      
end