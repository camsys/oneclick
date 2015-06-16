class UserRelationshipDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all

def buttons
    rtn = ""
    unless object.nil? # return a blank if no relationship exists
      if object.revokable
        rtn << button_tag(TranslationEngine.translate_text(:revoke), type: "button", data: {source: check_update_user_relationship_path(object, status: RelationshipStatus::REVOKED) }, class: "btn btn-default action-button")
      end
      if object.acceptable
        rtn << button_tag(TranslationEngine.translate_text(:accept), type: "button", data: {source: check_update_user_relationship_path(object, status: RelationshipStatus::CONFIRMED) }, class: "btn btn-default action-button")
      end
      if object.declinable
        rtn << button_tag(TranslationEngine.translate_text(:decline), type: "button", data: {source: check_update_user_relationship_path(object, status: RelationshipStatus::DENIED) }, class: "btn btn-default action-button")
      end
    end
    rtn.html_safe
  end

  def status
    unless object.nil?
      object.relationship_status.human_readable
    else 
      ""
    end
  end

  def assist_btn
    if object && object.confirmed
      link_to(TranslationEngine.translate_text(:assist),
              assist_user_path(id: object.delegate_id, buddy_id: object.user_id),
              {class: "btn btn-default action-button"})
    else
      status
    end
  end
  
end
