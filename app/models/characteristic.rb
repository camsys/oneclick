class Characteristic < ActiveRecord::Base
  include EligibilityOperators

  # attr_accessible :id, :code, :name, :note, :datatype, :active, :characteristic_type, :desc, :sequence

  has_many :user_characteristics
  has_many :user_profiles, through: :user_characteristics

  has_many :service_characteristics
  has_many :services, through: :service_characteristics

  # set the default scope
  default_scope {where('characteristics.active = ?', true)}
  scope :active, -> {where(active: true)}
  scope :enabled, -> {where('datatype != ?', 'disabled')}
  scope :personal_factors, -> {where('characteristic_type = ?', 'personal_factor')}
  scope :programs, -> {where('characteristic_type = ?', 'program')}
  scope :enabled, -> { where.not(datatype: 'disabled') }

  # return name value pairs suitable for passing to simple_form collection
  def self.form_collection include_all=true
    if include_all
      list = [[I18n.t(:all), -1]]
    else
      list = []
    end
    enabled.where(datatype: 'bool').order(name: :asc).each do |c|
      list << [I18n.t(c.name), c.id]
    end
    list
  end
  
  # builds a hash of details about a characteristic; is used by the javascript
  # client to knwo whether to ask the user for more info
  def for_missing_info(service, group, code)
    a = attributes
    sc = service_characteristics.where(service: service).take
    value = case a['code']
    when 'age'
      Date.today.year - sc.value.to_i
    else
      sc.value
    end
    operator = case a['code']
    when 'age'
      reverse_relationship_to_symbol(sc.value_relationship_id)
    else
      relationship_to_symbol(sc.value_relationship_id)
    end
    options = a['datatype']=='bool' ? [{text: I18n.t(:yes_str), value: true}, {text: I18n.t(:no_str), value: false}] : nil
    {
      'question' => I18n.t(a['note']),
      #'description' => I18n.t(a['desc']),
      'data_type' => a['datatype'],
      # 'control_type' => '',
      'options' => options,
      'success_condition' => "#{operator}#{value}",
      'group_id' => group,
      'code' => code
    }
  end

end
