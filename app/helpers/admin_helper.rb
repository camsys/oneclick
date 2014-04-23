module AdminHelper

  ACTION_ICONS = {
    new: 'fa fa-edit',
    edit: 'fa fa-edit',
    delete: 'fa fa-eraser'
  }

  def icon_label(action)
    "<i class='icon #{ACTION_ICONS[action]}'>&nbsp;</i>#{t(action)}".html_safe
  end
end
