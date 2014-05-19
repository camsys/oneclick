module Trip::Modes
  extend ActiveSupport::Concern

  included do
    attr_accessor :modes
    validate :at_least_one_mode
  end

  def at_least_one_mode
    unless (modes.reject {|m| m.blank?}).size > 0
      errors.add(:modes, "at least one mode must be selected")
    end
  end

end
