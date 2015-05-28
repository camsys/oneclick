class TripPurpose < ActiveRecord::Base

  has_many :service_trip_purpose_maps

  #attr_accessible :id, :name, :note, :active, :sort_order, :code

  validates :code, uniqueness: true

  default_scope {order("sort_order ASC")}
  # To alphabetize these in their localized version, we need to manually join them, since Translations don't have associations to any other AR models.
  # Note the "unscoped" to remove the default scope, as that would have been prepended on the SQL and prevented meaningful sorting...
  scope :ordered_by_localized_name, -> { unscoped.joins("INNER JOIN translations on trip_purposes.name = translations.key").where(translations: {locale: I18n.locale}).order("translations.value") }

  # return name value pairs suitable for passing to simple_form collection
  def self.form_collection include_all=true
    if include_all
      list = [[TranslationEngine.translate_text(:all), -1]]
    else
      list = []
    end
    ordered_by_localized_name.where(active: true).each do |p|
      list << [TranslationEngine.translate_text(p.name), p.id]
    end
    list
  end

  def to_s
    name
  end

end
