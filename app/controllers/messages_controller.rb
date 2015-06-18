class MessagesController < ApplicationController
  def create
    new_message_params = message_params
    new_message_params[:from_date] = Chronic.parse(message_params[:from_date])
    new_message_params[:to_date] = Chronic.parse(message_params[:to_date])
    
    @message = Message.new new_message_params
    authorize! :create, @message
    @message.sender = current_user

    if @message.save
      UserMessenger.new(@message.id, recipient_ids).send
    end
    
    respond_to do |format|
      format.js
    end
  end

  private 

  def message_params
    params.require(:message).permit(:body, :from_date, :to_date)
  end

  def recipient_ids
    params[:recipient_ids].split(',').map(&:to_i)
  end
end
