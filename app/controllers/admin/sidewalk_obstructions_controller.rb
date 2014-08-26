class Admin::SidewalkObstructionsController < ApplicationController
  
  def index
    authorize! :read, SidewalkObstruction
    authorize! :approve, SidewalkObstruction
    @sidewalk_obstructions = SidewalkObstruction.pending.all
  end

  def approve
    authorize! :approve, SidewalkObstruction
    parsed_feedbacks = Rack::Utils.parse_query(params[:approve]) # data serialized for AJAX call.  Must parse from query-string
    parsed_feedbacks.each do |k,v|
      SidewalkObstruction.find(k).update_attributes(status: v)
    end

    flash[:notice] = t(:sidewalk_obstructions_update, count: parsed_feedbacks.count) if parsed_feedbacks.count != 0
    respond_to do |format|
      format.js {render nothing: true}
      format.html {redirect_to action: :index}
    end
  end

  private
  
  def update_feedback_status(feedback_id, status)
    feedback = SidewalkObstruction.where(id: feedback_id).first
    unless feedback.nil?
      is_authorized = false
      case status
      when SidewalkObstruction::APPROVED
        is_authorized = is_admin?
      when SidewalkObstruction::REJECTED
        is_authorized = is_admin?
      when SidewalkObstruction::DELETED
        is_authorized = (is_admin? or current_or_guest_user.id == feedback.user_id)
      end

      if is_authorized
        feedback.update_attributes(status: status)

        return {
          success: true,
          feedback_data: feedback,
          feedback_allow_actions: get_feedback_allow_actions(feedback)
        }
      else
        return {
          success: false,
          error_msg: I18n.t(:not_authorized_as_an_administrator)
        }
      end
    else
      return {
        success: false,
        error_msg: I18n.t(:something_went_wrong)
      } 
    end
  end

  def get_feedback_allow_actions(feedback)
    return {
      is_approvable: (feedback.pending? and is_admin?),
      is_deletable: (is_admin? or current_or_guest_user.id == feedback.user.id)
    } 
  end

  def is_admin?
    current_user and (current_user.has_role?(:admin) or current_user.has_role?(:system_administrator))
  end

end
