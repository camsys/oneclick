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
end
