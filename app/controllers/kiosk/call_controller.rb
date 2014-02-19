class Kiosk::CallController < ApplicationController
  layout 'kiosk/call'

  def index
    show
  end

  def show
    # Find these values at twilio.com/user/account
    account_sid = 'AC8ce255eb06b3f705093906a659782983'
    auth_token = 'aa3b2c0dbfa4f028ffa2e7dd414cef95'

    # This application sid will play a Welcome Message.
    demo_app_sid = 'AP09ed565cff2c9960e91463cf78fc5201'
    capability = Twilio::Util::Capability.new account_sid, auth_token
    capability.allow_client_outgoing demo_app_sid
    @token = capability.generate(10000)
    @number = params[:id]
  end

  def outgoing
    @caller_id = '+16467620669'
    number = params[:PhoneNumber]

    response = Twilio::TwiML::Response.new do |r|
      # Should be your Twilio Number or a verified Caller ID
      r.Dial :callerId => @caller_id do |d|
        # Test to see if the PhoneNumber is a number, or a Client ID. In
        # this case, we detect a Client ID by the presence of non-numbers
        # in the PhoneNumber parameter.
        if /^[\d\+\-\(\) ]+$/.match(number)
          number_to_call = CGI.escapeHTML(number)
          # raise number_to_call.inspect
          d.Number number_to_call
        else
          raise "Invalid number #{number}"
        end
      end
    end

    render xml: response.text
  end

protected

  def back_url
    '/kiosk'
  end
end
