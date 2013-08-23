require 'awesome_print'

class TripPlace < Place
  self.table_name = 'trip_places'
  attr_accessible :trip_id, :sequence
  validate :any_present?

  def any_present?
    if %w(nongeocoded_address address).all?{|attr| self[attr].blank?}
      errors.add :nongeocoded_address, I18n.translate(:address_is_required)
      errors.add :address, I18n.translate(:address_is_required)
      return false
    end
    true
  end

  belongs_to :trip

  before_save :do_before_save

  def do_before_save
    if trip.nil?
      # puts "No trip, just using place as is: #{self.inspect}"
    elsif trip.owner.nil?
      # puts "No trip owner, just using place as is:\n#{trip.inspect}\n#{self.inspect}"
    else
      user_place = UserPlace.find_by_name_and_user_id nongeocoded_address, trip.owner.id
      unless user_place.nil?
        update_attributes user_place.attributes.except('id', 'user_id', 'created_at', 'updated_at')
      end
    end
    geocode! unless geocoded?
  end

end
