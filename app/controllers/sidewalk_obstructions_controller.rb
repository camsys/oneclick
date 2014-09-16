class SidewalkObstructionsController < ApplicationController

  def create
    feedback = SidewalkObstruction.new
    feedback.user = current_or_guest_user
    feedback.lat = params[:lat]
    feedback.lon = params[:lon]
    feedback.removed_at = Date.strptime(params[:removed_at], '%m/%d/%Y') rescue nil
    feedback.comment = params[:comment]

    is_success = feedback.save rescue nil
    unless is_success.nil?
      respond_to do |format|
        format.json { render json: {
          success: true,
          feedback_data: feedback,
          feedback_allow_actions: get_feedback_allow_actions(feedback)
        }}
      end
    else
      respond_to do |format|
        format.json { render json: {
          success: false,
          error_msg: I18n.t(:something_went_wrong)
        }}
      end
    end

  end

  def approve
    respond_to do |format|
      format.json { render json: update_feedback_status(params[:id], SidewalkObstruction::APPROVED) }
    end
  end

  def reject
    respond_to do |format|
      format.json { render json: update_feedback_status(params[:id], SidewalkObstruction::REJECTED) }
    end
  end

  def delete
    respond_to do |format|
      format.json { render json: update_feedback_status(params[:id], SidewalkObstruction::DELETED) }
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
    can? :manage, :all
  end

end
