module AdminHelper

  ACTION_ICONS = {
    new: 'fa fa-edit',
    edit: 'fa fa-edit',
    delete: 'fa fa-eraser',
    apply: 'fa fa-check',
    cancel: 'fa fa-times'
  }

  def icon_label(action)
    # "<i class='icon #{ACTION_ICONS[action]}'>&nbsp;</i>#{t(action)}".html_safe
    "#{t(action)}".html_safe
  end

  # Construct a name for an iput control appropriate for setting nested attributes
  def input_name form_builder, nest, attribute=nil, count=nil
    name = form_builder.object_name + '[' + nest.to_s + '_attributes]['
    name += count.to_s if !count.nil?
    name += '][' + attribute.to_s + ']' if !attribute.nil?
    name
  end
  
end
