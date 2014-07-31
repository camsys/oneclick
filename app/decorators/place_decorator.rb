class PlaceDecorator < Draper::Decorator
  delegate_all

  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  #   def created_at
  #     helpers.content_tag :span, class: 'time' do
  #       object.created_at.strftime("%a %m/%d/%y")
  #     end
  #   end

  def label
    object.name
  end

  def icon
    LeafletHelper.marker(('A'..'Z').to_a[context[:i]])
  end

  def cs_json
    {address: raw_address, placename: name, json: to_json}.to_json
  end

end
