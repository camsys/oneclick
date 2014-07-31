class UserDecorator < Draper::Decorator
  delegate_all

  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  #   def created_at
  #     helpers.content_tag :span, class: 'time' do
  #       object.created_at.strftime("%a %m/%d/%y")
  #     end
  #   end

  def delegate_presentation(user)
    if object.can_assist_target?(user)
      h.link_to traveler_retract_user_user_relationship_path
    end
  end

  def traveler_presentation
  end

end
