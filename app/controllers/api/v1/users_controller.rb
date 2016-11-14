module Api
  module V1
    class UsersController < Api::V1::ApiController

      def update
        @traveler.update_profile params
        valid = @traveler.valid?
        #Update accommodations and characteristics


        if !valid
          Rails.logger.error(@traveler.errors.messages)
          hash = {result: false, message: "Unable to update user profile do the following error: #{@traveler.errors.messages}"}
        else
          @traveler.save
          hash = {result: true, message: "User updated."}
        end

        render json: hash and return
      end

      def profile
        hash = {first_name: @traveler.first_name, last_name: @traveler.last_name}

        #Don't send an email address if it's just the default ecolane email
        email = @traveler.email
        if email.include? "@ecolane_user.com"
          email = ""
        end
        hash[:email] =  email

        #Walking Speed
        walking_speed = @traveler.walking_speed
        unless walking_speed.nil?
          hash[:walking_speed] = walking_speed.code
        else
          hash[:walking_speed] = "average"
        end

        #Walking Distance
        walking_distance = @traveler.walking_maximum_distance
        unless walking_distance.nil?
          hash[:walking_distance] = walking_distance.value
        else
          hash[:walking_distance] = 2.0
        end

        #Ecolane Id
        user_service = @traveler.user_profile.user_services.first #there should only ever be one
        unless user_service.nil?
          hash[:ecolane_id] = user_service.external_user_id
        else
          hash[:ecolane_id] = nil
        end

        hash[:lang] = @traveler.preferred_locale

        render json: hash

      end

      def walk_speed_to_code(walk_speed)
        walk_speed = walk_speed.downcase.strip.to_sym
        walk_speed_hash = {slow: "slow", average: "average", medium: "average", fast:"fast"}
        return walk_speed_hash[walk_speed]
      end

    end
  end
end