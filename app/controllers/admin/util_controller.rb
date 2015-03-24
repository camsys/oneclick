class Admin::UtilController < Admin::BaseController
  skip_authorization_check
  include TripsSupport

  def geocode
    @results = nil
    @address = params[:geocode][:address] rescue nil
    @map_center = params[:geocode][:map_center] rescue nil
    if @address
      g = OneclickGeocoder.new
      @results = Geocoder.search(params[:geocode][:address], sensor: g.sensor, components: g.components, bounds: g.bounds)
      @autocomplete_results = google_api.get('autocomplete/json') do |req|
        req.params['input']    = @address
        req.params['key']      = Oneclick::Application.config.google_places_api_key
        req.params['location'] = @map_center
        req.params['radius']   = Oneclick::Application.config.config.google_radius_meters
        req.params['components'] = Oneclick::Application.config.geocoder_components
      end

      @autocomplete_details = @autocomplete_results.body['predictions'].collect do |p|
        get_places_autocomplete_details(p['place_id'], p['reference']).body
      end
    end
  end

  #def raise
  #  raise (params[:string] || 'Raising an exception')
  #end

  class App
    include ActiveModel::AttributeMethods
    attr_accessor :name, :url
    # define_attribute_methods :name, :url
    def initialize(attributes = {})
      attributes.each do |name, value|
        send("#{name}=", value)
      end
    end
  end

  APPS = [
    App.new(name: 'oneclick-arc', url: 'postgres://ddvlsttgonsarn:zCA0ZdLZqbQh40RXC6mh4EbbKZ@ec2-54-204-16-70.compute-1.amazonaws.com:5432/d40i8b2ppro5ce'),
    App.new(name: 'oneclick-arc-int', url: 'postgres://mwjfslauxwmbvc:4E9Wesefl8I6QFjGj-N11zo0Qn@ec2-107-21-112-215.compute-1.amazonaws.com:5432/dagmphqt3s3ljk'),
    App.new(name: 'oneclick-arc-qa', url: 'postgres://wauztosctuedwq:5evwGWYpt4dT0-5CeUZjag_9TO@ec2-107-21-226-77.compute-1.amazonaws.com:5432/dbtdi87u2af3r7'),
    App.new(name: 'oneclick-broward', url: 'postgres://sgvmjzcshqaezc:lrDACPWH09EiGuDGQfA2-vdU28@ec2-54-235-74-57.compute-1.amazonaws.com:5432/dvdlfla69ahfp'),
    App.new(name: 'oneclick-broward-qa', url: 'postgres://oasqgbrnspblgc:_HIiEswDYpkdqz5g6UdLTO1viL@ec2-54-204-2-255.compute-1.amazonaws.com:5432/d5c9hfa0hqkvs0'),
    App.new(name: 'oneclick-kiosk', url: 'postgres://bwslcudczznuve:1nwlq2CnGMkJ6QxCav22OKHObQ@ec2-54-204-45-126.compute-1.amazonaws.com:5432/dfq82niigrmn8o'),
    App.new(name: 'oneclick-pa', url: 'postgres://qvrriuowyaukil:E1hWyshrglwiqx3JLMRbvr-L1P@ec2-107-20-214-225.compute-1.amazonaws.com:5432/df4sho1ano8fqt'),
    App.new(name: 'oneclick-pa-qa', url: 'postgres://rbdccsbawortbj:uEPV2v_w8zKAn8UolxnUNOofXs@ec2-54-204-16-70.compute-1.amazonaws.com:5432/dfdsv77hi7h6qh'),
  ]

  def services
    @apps = APPS
    if params[:services]
      if params[:services][:app]
        url = params[:services][:app]
        @name = (APPS.find {|a| a.url==url}).name
        ActiveRecord::Base.establish_connection(url)
        @results = JSON.pretty_generate(
          JSON.parse(
            Provider.all.to_json(
              include:
              {
                services: {
                  include:
                  [
                    :service_type,
                    :fare_structures,
                    :schedules,
                    {service_accommodations: {include: :accommodation}},
                    {service_characteristics: {include: :characteristic}},
                    {service_trip_purpose_maps: {include: :trip_purpose}},
                    {service_coverage_maps: {include: :geo_coverage}},
                    :user_services,
                  ]
                }
              }
            )
          )
        )
      end
    end
  end

  def settings
    authorize! :settings, :util
  end

  def upload_application_logo
    info_msgs = []
    error_msgs = []
    if !can?(:upload_application_logo, :util)
      error_msgs << t(:not_authorized)
    else
      file = params[:logo][:file] if params[:logo]
      
      if !file.nil?
        uploader = ApplicationLogoUploader.new
        begin
          uploader.store!(file)
        rescue Exception => ex
          error_msgs << ex.message
        end

        if OneclickConfiguration.create_or_update(:ui_logo, uploader.url)
          info_msgs << t(:logo) + " " + t(:was_successfully_updated)
        else
          error_msgs << t(:failed_to_update_application_logo)
        end
      else
        error_msgs << t(:select_image_to_upload)
      end
    end

    if error_msgs.size > 0
      flash[:error] = error_msgs.join(' ')
    elsif info_msgs.size > 0
      flash[:notice] = info_msgs.join(' ')
    end

    respond_to do |format|
      format.js
      format.html {redirect_to admin_settings_path}
    end
  end

end
