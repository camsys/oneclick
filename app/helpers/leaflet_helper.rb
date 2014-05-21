module LeafletHelper

  # Defaults
  MAPID = "map"
  MINZOOM = 1
  MAXZOOM = 18
  TILE_PROVIDER = 'CLOUDMADE'
  TILE_STYLE_ID = 997
  MAP_BOUNDS = Rails.application.config.map_bounds
  SCROLL_WHEEL_ZOOM = false
  
  def LeafletMap(options)
    options_with_indifferent_access = options.with_indifferent_access

    js_dependencies = Array.new
    #js_dependencies << 'http://cdn.leafletjs.com/leaflet-0.4/leaflet.js'
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
    
    mapopts = {
      :min_zoom => min_zoom,
      :max_zoom => max_zoom,
      :tile_provider => tile_provider,
      :tile_style_id => tile_style_id,
      scroll_wheel_zoom: scroll_wheel_zoom
    }.to_json

    js << "var CsMaps = CsMaps || {};"
    js << "CsMaps.#{mapid} = Object.create(CsLeaflet.Leaflet);"
    js << "m = CsMaps.#{mapid};"
    js << "m.init('#{mapid}', #{mapopts});"
    # add any markers
    js << "m.replaceMarkers(#{options[:markers]});" unless options[:markers].nil?
    # add any circles
    js << "m.addCircles(#{options[:circles]});" unless options[:circles].nil?
    # add any polylines
    js << "m.replacePolylines(#{options[:polylines]}, false);" unless options[:polylines].nil?
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
