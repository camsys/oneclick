class Mode < ActiveRecord::Base

  has_many :itineraries
  has_and_belongs_to_many :trips, join_table: :trips_desired_modes, foreign_key: :desired_mode_id

  belongs_to :parent, class_name: 'Mode'
  has_many :submodes, class_name: 'Mode', foreign_key: 'parent_id'

  # Updatable attributes
  # attr_accessible :id, :name, :active

  # set the default scope
  default_scope {where(active: true)}

  scope :top_level, -> { where parent_id: nil }

  begin
    Mode.unscoped.load.each do |mode|
      instance_method_name = (mode.code.split(/_/, 2).last + '?').to_sym
      class_method_name = mode.code.split(/_/, 2).last.to_sym
      define_method(instance_method_name) do
        code==mode.code
      end
      define_singleton_method(class_method_name) do
        unscoped.where(code: mode.code).first
      end
    end
  rescue Exception => e
    Rails.logger.info "Could not create Mode methods (normal during db ops)."
  end

  # def self.transit
  #   unscoped.where("code = 'mode_transit'").first
  # end

  # def self.paratransit
  #   unscoped.where("code = 'mode_paratransit'").first
  # end

  # def self.taxi
  #   unscoped.where("code = 'mode_taxi'").first
  # end

  # def self.rideshare
  #   unscoped.where("code = 'mode_rideshare'").first
  # end

  # def self.bus
  #   unscoped.where("code = 'mode_bus'").first
  # end

  # def self.rail
  #   unscoped.where("code = 'mode_rail'").first
  # end

  # def self.walk
  #   unscoped.where("code = 'mode_walk'").first
  # end

  def self.transit_submodes
    if not transit
      none
    else
      transit.submodes
    end
  end

  def self.setup_modes(session_mode_codes)
    q = session_mode_codes ? Mode.where('code in (?)', session_mode_codes) : Mode.all
    non_transit_modes = Mode.top_level.where("code <> 'mode_transit'").where(visible: true)
      .sort{|a, b| I18n.t(a.name) <=> I18n.t(b.name)}.collect do |m|
      [I18n.t(m.name).html_safe, m.code]
    end
    transit = Mode.transit
    if transit.visible
      non_transit_modes << [I18n.t(transit.name).html_safe, transit.code]
      transit_modes = transit_submodes.where(visible: true).sort{|a, b| I18n.t(a.name) <=> I18n.t(b.name)}.collect do |t|
        [I18n.t(t.name).html_safe, t.code]
      end
    else
      transit_modes = []
    end

    selected_modes = q.collect{|m| m.code}
    return {modes: non_transit_modes, transit_modes: transit_modes, selected_modes: selected_modes}
  end

  def top_level?
    parent.blank?
  end

  def to_s
    name
  end

end
