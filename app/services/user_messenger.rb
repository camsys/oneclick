class UserMessenger

  attr_accessible :message_id, :recipient_ids

  def initialize(message_id, recipient_ids)
    @message_id = message_id
    @recipient_ids = recipient_ids
  end

  def send
    # mass insert
    user_message_ids = []
    recipient_ids.each do | recipient_id|
      user_message_ids.push "(#{recipient_id}, #{message_id})"
    end
    mass_insert_sql = "INSERT INTO user_messages (\"recipient_id\", \"message_id\") VALUES #{user_message_ids.join(", ")}"
    
    UserMessage.connection.execute mass_insert_sql
  end

end