# An accomodation a traveler might require, for example:
# code: 'folding_wheelchair_accessible'
# name: 'Folding wheelchair accessible.'
# note: 'Do you need a vehicle that has space for a folding wheelchair?'
# datatype: 'bool'
# sequence: integer
#
# Services have accommodations that they offer; users have accomodations that they require.
#
class Accommodation < ActiveRecord::Base
  include EligibilityHelpers
  
  # attr_accessible :id, :code, :name, :note, :datatype, :active

  has_many :user_accommodations
  has_many :user_profiles, through: :user_accommodations

  has_many :service_accommodations
  has_many :services, through: :service_accommodations

  # set the default scope
  default_scope {where('accommodations.active = ?', true)}
  scope :active, -> {where(active: true)}
  scope :enabled, -> { where.not(datatype: 'disabled') }
end
