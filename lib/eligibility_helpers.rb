module EligibilityHelpers

  def true_false_checked?(user, value)
    if self.class == Characteristic
      if user.user_characteristics.where(characteristic_id: self.id).empty?
        nil
      else
        (user.user_characteristics.where(characteristic_id: self.id).first.value == value) ? "checked" : nil
      end
    else
      if user.user_accommodations.where(accommodation_id: self.id).empty?
        nil
      else
        (user.user_accommodations.where(accommodation_id: self.id).first.value == value) ? "checked" : nil
      end
    end
  end

  def na_checked?(user)
    if self.class == Characteristic
      user.user_characteristics.where(characteristic_id: self.id).empty? ? "checked" : nil
    else 
      user.user_accommodations.where(accommodation_id: self.id).empty? ? "checked" : nil
    end
  end

  def selected_option(user)
    characteristics = user.user_characteristics.where(characteristic_id: self.id)
    accommodations = user.user_accommodations.where(accommodation_id: self.id)

    if self.class == Characteristic
      if characteristics.empty?
        UserProfileProxy::PARAM_NOT_SET
      else
        characteristics.first.value
      end
    else
      if accommodations.empty?
        UserProfileProxy::PARAM_NOT_SET
      else
        accommodations.first.value
      end
    end
  end

end


  
