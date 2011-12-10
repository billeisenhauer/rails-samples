module InventoryAssetsHelper
  
  def inventory_assets_title
    age_qualifier = params[:older] ? 'Archived' : 'Active'
    state_qualifier = color_to_state(params[:for_state])
    "#{age_qualifier}#{state_qualifier} Inventory Assets"
  end
  
  def display_amount(field)
    current_user.guest? ? 'HIDDEN' : number_to_currency(field)
  end
  
  def last_seen_at_for(inventory_asset)
    inventory_asset.last_seen_at ? inventory_asset.last_seen_at.to_s(:us_with_time) : 'Never'
  end
  
  def destroy_inventory_asset_link(inventory_asset)
    link_to(
      image_tag('application_delete.png', :alt => "Delete this inventory asset", :title => "Delete this inventory asset"),
      { :action => "destroy", :id => inventory_asset },
      :confirm => "Are you sure you want to delete this inventory asset?",
      :method => :delete
    )
  end
  
  def edit_inventory_asset_link(inventory_asset)
    link_to(
      image_tag('application_edit.png', :alt => 'Edit this inventory asset', :title => 'Edit this inventory asset'),
      edit_inventory_asset_path(inventory_asset)
    )
  end
  
  def split_inventory_asset_link(inventory_asset)
    link_to(
      image_tag('arrow_divide.png', :alt => 'Split this inventory asset', :title => 'Split this inventory asset'),
      new_split_inventory_asset_path(inventory_asset)
    )
  end  
  
  def inventory_asset_revisions_link(inventory_asset)
    link_to(
      image_tag('user_edit.png', :alt => 'View revisions for this inventory asset', :title => 'View revisions for this inventory asset'),
      inventory_asset_revisions_path(inventory_asset)
    )
  end
  
  def current_topic_class(link_name, current_link_name)
    link_name == current_link_name ? 'current-form-topic-link' : ''
  end
  
  def current_pane_style(link_name, current_link_name)
    link_name == current_link_name ? '' : 'display:none;'
  end
  
  def tag_number_for(inventory_asset)
    inventory_asset.tag ? inventory_asset.tag.tag_number : 'Untagged'
  end
  
  def inventory_asset_tag_options_for(inventory_asset, user)
    tags = Tag.for_site(user.site).unassigned
    tags << inventory_asset.tag if inventory_asset.tag
    tags.sort! { |a, b| a.tag_number.downcase <=> b.tag_number.downcase }
    tags_options = [['Unassigned', nil]]
    tags.each do |tag|
      tags_options << [tag.tag_number, tag.id]
    end
    tags_options
  end
  
  def tr_status_class_for(inventory_asset)
    return '' if inventory_asset.tr_status.nil?
    inventory_asset.tr_status ? "pass" : "fail"
  end
  
  def attachment_link_for(inventory_asset)
    return 'None' unless inventory_asset.attachment?
    url = inventory_asset.attachment.url.gsub(/\?\d{10}/, '')
    current_user.guest? ? inventory_asset.attachment_file_name : link_to(inventory_asset.attachment_file_name, url)
  end
  
  def tr_status_for(inventory_asset)
    unless inventory_asset.tr_status.nil?
      inventory_asset.tr_status ? 'PASS' : 'FAIL'
    else
      'UNREVIEWED'
    end
  end
  
  protected
  
    COLOR_TO_STATES = {
      'red' => ' Ordered',
      'yellow' => ' Received',
      'green' => ' Sold',
      'blue' => ' Installed'
      
    }
    def color_to_state(color)
      COLOR_TO_STATES[color] || ''
    end
  
end
