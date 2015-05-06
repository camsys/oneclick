class FareZonesController < ApplicationController

  def create
    info_msgs = []
    error_msgs = []

    if !can?(:create, FareZone)
      error_msgs << t(:not_authorized)
    else
      service = Service.find(params[:service_id])
      file = params[:fare_zone][:file] if params[:fare_zone]

      if !file.nil?

        if file.content_type.include?('zip')
          if service.fare_structures.count == 0
            FareStructure.create(service: service, fare_type: FareStructure::ZONE)
          end
          fare_structure = service.fare_structures.first
          
          if fare_structure.fare_type != FareStructure::ZONE
            fare_structure.update_attributes(fare_type: FareStructure::ZONE)
          end

          ZoneFare.where(fare_structure: fare_structure).delete_all
          fare_structure.zone_fares.clear
          FareZone.where(service: service).delete_all
          service.fare_zones.clear

          file_path = file.tempfile.path
          FareZone.parse_shapefile(file_path, service)

          if service.fare_zones.count == 0
            error_msgs <<  t(:no_fare_zones_identified)
          else
            @zones = FareZone.where(service: service).select(:id, :zone_id).order(:zone_id)
            @fares = {}
            @zones.each do |from_zone|
              @zones.each do |to_zone |
                from_zone_id = from_zone[:id]
                to_zone_id = to_zone[:id]
                @fares["from_#{from_zone_id}_to_#{to_zone_id}"] = {
                  id: ZoneFare.create(
                    from_zone_id: from_zone_id,
                    to_zone_id: to_zone_id,
                    fare_structure: fare_structure
                  ).id
                }
              end
            end
          end
        else
          error_msgs <<  t(:upload_zip_alert)
        end
      else
        error_msgs << t(:upload_shapefile)
      end
    end

    if error_msgs.size > 0
      @error_msgs = error_msgs.join(' ')
      @failure = true
    elsif info_msgs.size > 0
      @info_msgs = info_msgs.join(' ')
    end

    respond_to do |format|
      format.js
    end
  end
end
