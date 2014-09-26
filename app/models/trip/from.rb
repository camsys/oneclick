module Trip::From
  extend ActiveSupport::Concern

  included do
    # name or raw address of the end points selected by the user. The value could be the
    # name of an object (Place, POI), a previously used address (TripPlace) or a string
    # entered into the control by the user (Raw Address)
    attr_accessor :from_place, :from_is_home
    # Stores the type of selection made by the user for an end point. Defined
    # in PlaceSearchingConteoller
    #  1 = POI
    #  2 = CACHED_ADDRESS from TripPlaces
    #  3 = PLACE fro MyPlaces
    #  4 = RAW ADDRESS typed in
    attr_accessor :from_place_selected_type
    # The Id of an end point. Value depends on the type of end point selected
    # if POI -- the id of the POI selected
    # if CACHED ADDRESS -- the id of the TripPlace selected
    # if PLACE -- the id of the Place selected
    # if RAW ADDRESS -- the index of the address in the geocoder cache for that end point
    attr_accessor :from_place_selected
    attr_accessor :from_place_object

    # Other attributes that are used to cache trip data during edits and repeats
    #
    # geolocs
    attr_accessor :from_lat, :from_lon
    # addresses as they could be different from the name for POIS and places
    attr_accessor :from_raw_address

    # multi_origin places
    attr_accessor :multi_origin_places

    # Basic validations. Just checking that the form is complete
    validates :from_place, :presence => true

    # Make sure that the user made a selection for each end point.
    validate :validate_from_selection

  end

protected

  # Validation. Check that there has been a selection for the from place
  def validate_from_selection
    # TODO Just check that somethign was selected, for now
    return !from_place_object.nil?
    if from_place_selected.blank? || from_place_selected_type.blank?
      errors.add(:from_place, I18n.translate(:nothing_found))
      return false
    end
  end
end
