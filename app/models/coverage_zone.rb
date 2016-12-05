class CoverageZone < ActiveRecord::Base

  has_one :service

  # Converts a recipe into a well-formed array
  def self.clean_recipe(recipe)
    if recipe.is_a?(Array)
      return recipe.map{ |area| area.to_s }
    else
      return recipe.to_s.split(',').map(&:strip)
    end
  end

  # Parses a coverage area "recipe" string into an array of matching County, Zipcode, and City objects
  def self.parse_coverage_recipe(recipe)
    parsed_recipe = CoverageZone.clean_recipe(recipe)

    # Create a hash with an array of matches for each area name.
    matched_areas = parsed_recipe.each_with_object({}) do |area_recipe, match_hash|

      # Look for any bracketed specifiers in the recipe string, and if they exist separate them out
      area_recipe = area_recipe.split(/[\[\]\(\)]/)
      unless area_recipe.empty?
        area_name = area_recipe.first.strip.titleize
        specifiers = area_recipe.length > 1 ? area_recipe[1].split('-') : []
        type_specifier = specifiers.length > 0 ? specifiers[0].strip.titleize : nil
        state_specifier = specifiers.length > 1 ? specifiers[1].strip.upcase : nil

        # Set the search tables and state filter based on specifiers if they exist, or on config variables if not
        search_tables = type_specifier ? [type_specifier] : Oneclick::Application.config.coverage_area_tables
        state_filter = state_specifier ? [state_specifier] : [Oneclick::Application.config.state]

        # Make a hash key for the area name, and fill it with an array of matching objects from the database
        match_hash[area_name] = [] unless match_hash.key?(area_name)
        search_tables.each do |table|
          case table
          when "County"
            match_hash[area_name] += County.where(name: area_name, state: state_filter)
          when "Zipcode"
            match_hash[area_name] += Zipcode.where(zipcode: area_name)
          when "City"
            match_hash[area_name] += City.where(name: area_name, state: state_filter)
          end
        end
      end
    end

    return matched_areas
  end

  # Encodes a hash of matching coverage areas into an unambiguous recipe string
  def self.encode_coverage_recipe(matched_areas)
    match_list = matched_areas.values.flatten.uniq
    match_list.map! do |area|
      case area.class.name
      when "County"
        "#{area.name} [#{area.class.name}-#{area.state}]"
      when "Zipcode"
        "#{area.zipcode} [#{area.class.name}]"
      else
        "#{area.name} [#{area.class.name}-#{area.state}]"
      end
    end.join(", ")
  end

  # Creates a new CoverageZone based on the passed recipe
  def self.build_coverage_area(recipe)
    parsed_recipe = self.parse_coverage_recipe(recipe)
    geoms = parsed_recipe.values.flatten.map {|obj| obj.geom}
    geom = geoms.reduce { |combined_area, geom| combined_area.union(geom) }
    geom = RGeo::Feature.cast(geom, :type => RGeo::Feature::MultiPolygon) unless geom.nil?
    @coverage_zone = self.new(recipe: self.encode_coverage_recipe(parsed_recipe), geom: geom)

    # Add errors for no matches and multiple matches
    errors = { no_matches: parsed_recipe.select {|k,v| v.empty? }.keys, multiple_matches: parsed_recipe.select {|k,v| v.length > 1 }.keys }
    @coverage_zone.errors.add(:no_matches, " found for: " + errors[:no_matches].join(", ")) unless errors[:no_matches].empty?
    @coverage_zone.errors.add(:multiple_matches, " found for: " + errors[:multiple_matches].join(", ")) unless errors[:multiple_matches].empty?

    return @coverage_zone
  end

  # Returns an array of coverage zone polygon geoms
  def to_array
    myArray = []
    self.geom.each do |polygon|
      polygon_array = []
      ring_array  = []
      polygon.exterior_ring.points.each do |point|
        ring_array << [point.y, point.x]
      end
      polygon_array << ring_array

      polygon.interior_rings.each do |ring|
        ring_array = []
        ring.points.each do |point|
          ring_array << [point.y, point.x]
        end
        polygon_array << ring_array
      end
      myArray << polygon_array
    end
    myArray
  end

  # Returns true if passed lat, long are within coverage zone's geom
  def contains?(lat, lng)
    point = RGeo::Geographic.simple_mercator_factory.point(lng.to_f, lat.to_f)
    geom && geom.contains?(point)
  end

  # Adds a new recipe to the existing recipe and parses it.
  def add_to_recipe(recipe_to_add)
    new_recipe = CoverageZone.clean_recipe(recipe_to_add) + CoverageZone.clean_recipe(self.recipe)
    CoverageZone.build_coverage_area(new_recipe)
  end

end
