module NotificationsHelper
  
  def field_select_options
    [
      ["Actual Delivery Date", "actual_delivery_on"], 
      ["Additional Amount", "additional_amount"],
      ["Category", "category"], 
      ["Client", "client_name"], 
      ["CoS", "cos"],  
      ["Engineering Amount", "engineering_amount"], 
      ["Expected Delivery Date", "expected_delivery_on"], 
      ["Field", "field"], 
      ["Flag", "state"],
      ["FO", "fo"], 
      ["FO Date", "fo_on"], 
      ["GR Date", "gr_on"], 
      ["Install Date", "installed_on"], 
      ["Lead Time (Days)", "days_lead_time"],
      ["Location", "last_seen_location"], 
      ["OCS-G", "ocs_g"], 
      ["Order Date", "ordered_on"], 
      ["Part #", "part_number"], 
      ["PE", "pe"], 
      ["PO #", "po_number"], 
      ["Project", "project"], 
      ["Qty Ordered", "quantity_ordered"], 
      ["Qty Received", "quantity_received"], 
      ["Qty Installed", "quantity_installed"], 
      ["Qty on Location", "quantity_on_location"],
      ["RFQ", "rfq_number"], 
      ["Serial Number", "serial_number"], 
      ["Shipping Amount", "shipping_amount"], 
      ["Sub Category", "sub_category"], 
      ["Total Cost Amount", "total_cost_amount"], 
      ["Total Sales Amount", "total_sales_amount"], 
      ["TR Date", "tr_on"], 
      ["Unit Cost Amount", "unit_cost_amount"], 
      ["Unit Sales Amount", "unit_sales_amount"], 
      ["Unit of Measurement", "measurement_unit"], 
      ["Vendor", "vendor"], 
      ["Well", "well"] 
    ]
  end
  
  def operator_select_options
    [["is", "=="], ["is not", "!="],["less than", "<"],["greater than", ">"]]
  end
  
end
