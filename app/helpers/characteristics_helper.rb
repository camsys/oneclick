module CharacteristicsHelper
  def active_button f, item, value
   f.object.send(item.code.to_sym) == value ? 'active' : ''
  end
end