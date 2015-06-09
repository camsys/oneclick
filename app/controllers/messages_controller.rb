class MessagesController < ApplicationController
  def create
    @message = Message.new message_params
    authorize! :create, @message
    @message.sender = current_user

    if !@message.save
      UserMessenger.new(@message.id, params[:recipients]).send
    end

    respond_to do |format|
      format.js
    end
  end

  private 

  def message_params
    params.require(:message).permit(:body, :from_date, :to_date)
  end
end
