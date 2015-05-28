module LeafletHelper

  # Defaults
  MAPID = "map"
  MINZOOM = 1
  MAXZOOM = 18
  TILE_PROVIDER = 'CLOUDMADE'
  TILE_STYLE_ID = 997
  MAP_BOUNDS = Rails.application.config.map_bounds
  SCROLL_WHEEL_ZOOM = false
  SHOW_MY_LOCATION = true
  SHOW_STREET_VIEW= true
  STREET_VIEW_URL = Rails.application.config.street_view_url
  SHOW_LOCATION_SELECT = false
  SHOW_SIDEWALK_FEEDBACK= true
  SIDEWALK_MARKER_ICON = 'sidewalkFeedbackIcon'
  MIN_SIDEWALK_ZOOM = 14

  ZOOM_ANIMATION = true

  def LeafletMap(options)
    options_with_indifferent_access = options.with_indifferent_access

    js_dependencies = Array.new
    #js_dependencies << '//cdn.leafletjs.com/leaflet-0.4/leaflet.js'
    #js_dependencies << 'leafletmap.js_x'
    #js_dependencies << 'leafletmap_icons.js_x'

    render :partial => '/leaflet/leaflet', :locals => { :options => options_with_indifferent_access, :js_dependencies => js_dependencies }
  end

  # Generates the Leaflet JS code to create the map from the options hash
  # passed in via the LeafletMap helper method
  def generate_map(options)
    js = []
    # Add any icon definitions
    js << options[:icons] unless options[:icons].nil?
    # init the map with the mapid, use default if not set
    mapid = options[:mapid] ? options[:mapid] : MAPID
    min_zoom = options[:min_zoom] ? options[:min_zoom] : MINZOOM
    max_zoom = options[:max_zoom] ? options[:max_zoom] : MAXZOOM
    tile_provider = options[:tile_provider] ? options[:tile_provider] : TILE_PROVIDER
    tile_style_id = options[:tile_style_id] ? options[:tile_style_id] : TILE_STYLE_ID
    scroll_wheel_zoom = options[:scroll_wheel_zoom] || SCROLL_WHEEL_ZOOM
    show_my_location = options[:show_my_location] || SHOW_MY_LOCATION
    show_street_view = options[:show_street_view] || SHOW_STREET_VIEW
    street_view_url = options[:street_view_url] ? options[:street_view_url] : STREET_VIEW_URL
    show_location_select = options[:show_location_select] || SHOW_LOCATION_SELECT
    zoom_animation = options[:zoom_animation] || ZOOM_ANIMATION
    show_sidewalk_feedback = options[:show_sidewalk_feedback] || SHOW_SIDEWALK_FEEDBACK
    sidewalk_feedback_editing_enabled = SidewalkObstruction.sidewalk_obstruction_on?
    if current_user.nil? #only for signed user
      sidewalk_feedback_editing_enabled = false
    end

    if show_sidewalk_feedback
      sidewalk_feedback_options = {
        editing_enabled: sidewalk_feedback_editing_enabled,
        submit_feedback_url: user_sidewalk_obstructions_path({:user_id => current_or_guest_user.id}),
        approve_feedback_url: approve_user_sidewalk_obstructions_path({:user_id => current_or_guest_user.id}),
        reject_feedback_url: reject_user_sidewalk_obstructions_path({:user_id => current_or_guest_user.id}),
        delete_feedback_url: delete_user_sidewalk_obstructions_path({:user_id => current_or_guest_user.id}),
        locale_text: {
          approve: TranslationEngine.translate_text(:approve),
          reject: TranslationEngine.translate_text(:reject),
          delete: TranslationEngine.translate_text(:delete),
          submit: TranslationEngine.translate_text(:submit),
          cancel: TranslationEngine.translate_text(:cancel),
          remove_by: TranslationEngine.translate_text(:remove_by),
          comments: TranslationEngine.translate_text(:comments)
        },
        icon_class: SIDEWALK_MARKER_ICON,
        min_visible_zoom: MIN_SIDEWALK_ZOOM
      }
    else
      sidewalk_feedback_options = {}
    end

    mapopts = {
      :min_zoom => min_zoom,
      :max_zoom => max_zoom,
      :tile_provider => tile_provider,
      :tile_style_id => tile_style_id,
      scroll_wheel_zoom: scroll_wheel_zoom,
      zoom_animation: zoom_animation,
      show_my_location: show_my_location,
      show_street_view: show_street_view,
      street_view_url: street_view_url,
      show_location_select: show_location_select,
      show_sidewalk_feedback: show_sidewalk_feedback,
      sidewalk_feedback_options: sidewalk_feedback_options,
      map_control_tooltips: {
        zoom_in: TranslationEngine.translate_text(:zoom_in),
        zoom_out: TranslationEngine.translate_text(:zoom_out),
        my_location: TranslationEngine.translate_text(:center_my_location),
        display_street_view: TranslationEngine.translate_text(:display_street_view),
        select_location_on_map: TranslationEngine.translate_text(:select_location_on_map),
        add_sidewalk_feedback_on_map: TranslationEngine.translate_text(:add_sidewalk_feedback_on_map)
      }
    }.to_json

    js << "var CsMaps = CsMaps || {};"
    js << "CsMaps.#{mapid} = Object.create(CsLeaflet.Leaflet);"
    js << "m = CsMaps.#{mapid};"
    js << "m.init('#{mapid}', #{mapopts});"
    # add any markers
    js << "m.replaceMarkers(#{options[:markers]});" unless options[:markers].nil?
    # add any sidewalk_feedback markers
    js << "m.replaceSidewalkFeedbackMarkers(#{options[:sidewalk_feedback_markers]});" unless options[:sidewalk_feedback_markers].nil? if show_sidewalk_feedback
    # add any circles
    js << "m.addCircles(#{options[:circles]});" unless options[:circles].nil?
    # add any polylines
    js << "m.replacePolylines(#{options[:polylines]}, false);" unless options[:polylines].nil?
    # add any multipolygons
    js << "m.addMultipolygons(#{options[:multipolygons]}, false);" unless options[:multipolygons].nil?
    # set the map bounds
    js << "m.setMapBounds(#{MAP_BOUNDS[0][0]},#{MAP_BOUNDS[0][1]},#{MAP_BOUNDS[1][0]},#{MAP_BOUNDS[1][1]});"
    js << "m.cacheMapBounds(#{MAP_BOUNDS[0][0]},#{MAP_BOUNDS[0][1]},#{MAP_BOUNDS[1][0]},#{MAP_BOUNDS[1][1]});"
    js << "m.showMap();"
    js << "m.LMmap.setZoom(#{options[:zoom]});" if options[:zoom].present?
    js * ("\n")
  end

  def self.marker(letter)
    "http://maps.google.com/mapfiles/marker_green#{letter}.png"
  end

end