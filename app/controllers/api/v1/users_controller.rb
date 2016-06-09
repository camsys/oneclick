module Api
  module V1
    class UsersController < Api::V1::ApiController

      def update
        attributes = params[:attributes]
        attributes.each do |key, value|
          case key.to_sym
            when :first_name
              @traveler.first_name = value
            when :last_name
              @traveler.last_name = value
            when :email
              @traveler.email = value
            when :walking_speed
              walking_speed = WalkingSpeed.find_by(code: walk_speed_to_code(value))
              @traveler.walking_speed = walking_speed
            when :walking_distance
              walking_maximum_distance = WalkingMaximumDistance.find_by(value: value.to_f)
              @traveler.walking_maximum_distance = walking_maximum_distance
            when :ecolane_id
              @traveler.user_profile.user_services.each do |user_service|
                user_service.external_user_id = value.to_s
                user_service.save
              end
            else
              hash = {result: false, message: "Unknown attribute " + key.to_s}
              render json: hash and return
          end
        end

        @traveler.save
        hash = {result: true, message: "User updated."}
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