class Characteristic < ActiveRecord::Base
  include EligibilityOperators

  # attr_accessible :id, :code, :name, :note, :datatype, :active, :characteristic_type, :desc

  has_many :user_characteristics
  has_many :user_profiles, through: :user_characteristics

  has_many :service_characteristics
  has_many :services, through: :service_characteristics

  # set the default scope
  default_scope {where('characteristics.active = ?', true)}
  scope :personal_factors, -> {where('characteristic_type = ?', 'personal_factor')}
  scope :programs, -> {where('characteristic_type = ?', 'program')}
  scope :enabled, -> { where.not(datatype: 'disabled') }
  
  # builds a hash of details about a characteristic; is used by the javascript
  # client to knwo whether to ask the user for more info
  def for_missing_info(service)
    a = attributes
    sc = service_characteristics.where(service: service).take
    options = a['datatype']=='bool' ? [{t(:yes_str) => true}, {t(:no_str) => false}] : nil
    {
      'question' => I18n.t(a['note']),
      'description' => I18n.t(a['desc']),
      'data_type' => a['datatype'],
      # 'control_type' => '',
      'options' => options,
      'success_condition' => "#{relationship_to_symbol(sc.value_relationship_id)}#{sc.value}",
    }
  end

end
