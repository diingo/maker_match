module GladiatorMatch
  class UpdateUser < UseCase
    def run(inputs)
      user = GladiatorMatch.db.get_user_by_session(inputs[:session_key])

      return failure(:no_user_with_that_session_key) if user.nil?

      if inputs[:interests]
        return failure(:invalid_interest) unless valid_interests?(inputs[:interests])
        user.interests = inputs[:interests]
      end

      if inputs[:location]
        lat_long_arr = Geocoder.coordinates(inputs[:location])
        return failure(:invalid_location) if lat_long_arr.nil?

        lat = lat_long_arr[0]
        long = lat_long_arr[1]

        user.latitude = lat
        user.longitude = long
      end

      if inputs[:first_name] || inputs[:last_name]
        return failure(:invalid_name) unless valid_names?(inputs)
        user.first_name = inputs[:first_name] if inputs[:first_name]
        user.last_name = inputs[:last_name] if inputs[:last_name]
      end

      unless inputs[:remote].nil?
        return failure(:invalid_remote_type) unless is_boolean?(inputs[:remote])
        user.remote = inputs[:remote]
      end

      GladiatorMatch.db.update_user(user)

      updated_user = GladiatorMatch.db.get_user(user.id)

      return success(user: updated_user)
    end

    def valid_interests?(interests)
      interests.class == Array && interests.nil? == false && interests.empty? == false
    end

    def valid_names?(inputs)
      # order is important here because nil.empty? will return error
      # is this a good way to do this? - can try activesupport gem to use method blank?
      inputs[:first_name].nil? == false && inputs[:last_name].nil? == false && inputs[:first_name].empty? == false && inputs[:last_name].empty? == false
    end

    def is_boolean?(remote)
      remote.class == TrueClass || remote.class == FalseClass
    end
  end
end