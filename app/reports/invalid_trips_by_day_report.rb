class InvalidTripsByDayReport < AbstractReport

  def initialize(attributes = {})
    super(attributes)
  end    
  
protected
  
  def get_data(current_user, params)
    
    # Check to see if we got an asset type to sub select on
    if params[:report_filter_type] 
      report_filter_type = params[:report_filter_type].to_i
    else
      report_filter_type = 0
    end
        
    # get the list of assets for this agency
    if report_filter_type > 0
      assets = current_user.organization.assets.where('asset_type_id = ?', report_filter_type)
    else
      assets = current_user.organization.assets
    end

    # backlog is with respect to the end of the last fiscal year
    analysis_date = (Date.today - 1.year).end_of_year

    a = {}
    assets.each do |asset|
      if asset.is_in_backlog(analysis_date)
        # see if this asset sub type has been seen yet
        if a.has_key?(asset.asset_subtype)
          report_row = a[asset.asset_subtype]
        else
          report_row = AssetSubtypeReportRow.new(asset.asset_subtype)
          a[asset.asset_subtype] = report_row
        end
        # get the replacement cost for this item based on the current policy
        report_row.add(asset)
      end
    end   
    return a          
  end
    
end
