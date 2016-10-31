class CoverageZone < ActiveRecord::Base

  has_one :service

  # Parses a coverage area "recipe" string into an array of matching County, Zipcode, and City objects
  def self.parse_coverage_recipe(recipe)
    parsed_recipe = recipe.split(',').map(&:strip)

    # Create a hash with an array of matches for each area name.
    matched_areas = parsed_recipe.each_with_object({}) do |area_recipe, match_hash|

      # Look for any bracketed specifiers in the recipe string, and if they exist separate them out
      area_recipe = area_recipe.split(/[\[\]\(\)]/)
      area_name = area_recipe.first.strip.titleize
      specifiers = area_recipe.length > 1 ? area_recipe[1].split('-') : []
      type_specifier = specifiers.length > 0 ? specifiers[0].strip.titleize : nil
      state_specifier = specifiers.length > 1 ? specifiers[1].strip.upcase : nil

      # Set the search tables and state filter based on specifiers if they exist, or on config variables if not
      search_tables = type_specifier ? [type_specifier] : Oneclick::Application.config.coverage_area_tables
      state_filter = state_specifier ? [state_specifier] : [Oneclick::Application.config.state]
      # state_filter = state_specifier ? [state_specifier] : ["MA", "CT", "VA"]

      # Make a hash key for the area name, and fill it with an array of matching objects from the database
      match_hash[area_name] = [] unless match_hash.key?(area_name)
      search_tables.each do |table|
        case table
        when "County"
          # match_hash[area_name] += County.where(name: area_name, state: state_filter).map {|area| {id: area.id, name: area.name, state: area.state}}
          match_hash[area_name] += County.where(name: area_name, state: state_filter)
        when "Zipcode"
          # match_hash[area_name] += Zipcode.where(zipcode: area_name).map {|area| {id: area.id, zipcode: area.zipcode, name: area.name, state: area.state}}
          match_hash[area_name] += Zipcode.where(zipcode: area_name)
        when "City"
          match_hash[area_name] += City.where(name: area_name, state: state_filter)
        end
      end
    end

    # puts matched_areas.ai
    return matched_areas
  end

  # Encodes a hash of matching coverage areas into an unambiguous recipe string
  def self.encode_coverage_recipe(matched_areas)
    match_list = matched_areas.values.flatten
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
    return self.new(recipe: self.encode_coverage_recipe(parsed_recipe), geom: geoms.reduce { |combined_area, geom| combined_area.union(geom) })
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

end
