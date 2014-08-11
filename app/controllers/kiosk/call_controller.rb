class Kiosk::CallController < ApplicationController
  layout 'kiosk/call'

  def index
    show
  end

  def show
    capability = Twilio::Util::Capability.new ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']
    capability.allow_client_outgoing ENV['TWILIO_APP_ID']
    @token = capability.generate(10000)
    @number = params[:id]
    render :show
  end

  def outgoing
    @caller_id = '+16467620669'
    number = params[:PhoneNumber]

    number = number.split('://').last if number =~ /^tel:\/\//

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
