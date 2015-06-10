class UserMessagesController < ApplicationController
  def mark_as_read
    @user_message = UserMessage.find(params[:id])

    status = @user_message.mark_as_read! if @user_message.try(:recipient) == current_user
    
    respond_to do |format|
      format.json { render json: {status: status} }
    end
  end
end
