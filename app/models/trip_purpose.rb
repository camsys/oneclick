class TripPurpose < ActiveRecord::Base

  has_many :service_trip_purpose_maps

  #attr_accessible :id, :name, :note, :active, :sort_order, :code

  validates :code, uniqueness: true

  default_scope {order("sort_order ASC")}
  # To alphabetize these in their localized version, we need to manually join them, since Translations don't have associations to any other AR models.
  # Note the "unscoped" to remove the default scope, as that would have been prepended on the SQL and prevented meaningful sorting...
  scope :ordered_by_localized_name, -> { unscoped.joins("INNER JOIN translations on trip_purposes.name = translations.key where translations.locale = '#{I18n.locale}' order by translations.value") }

  def to_s
    name
  end

end
