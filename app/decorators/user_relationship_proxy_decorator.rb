class UserRelationshipProxyDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all

  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  #   def created_at
  #     helpers.content_tag :span, class: 'time' do
  #       object.created_at.strftime("%a %m/%d/%y")
  #     end
  #   end
  def id
    object.you.id
  end

  def name
    object.you.name
  end

  def email
    object.you.email
  end

  def can_assist_me
    rel = object.can_assist_me
    UserRelationshipDecorator.decorate(rel).buttons
  end

  def i_can_assist
    rel = object.i_can_assist
    UserRelationshipDecorator.decorate(rel).buttons
  end
end