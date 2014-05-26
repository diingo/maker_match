module GladiatorMatch
  class CreateUser < UseCase
    def run(inputs)
      return failure(:invalid_login) if inputs[:github_login].empty?
      return failure(:invalid_interest) unless valid_interests?(inputs[:interests])

      lat_long_arr = Geocoder.coordinates(inputs[:location])
      return failure(:invalid_location) if lat_long_arr.nil?
      return failure(:invalid_name) unless valid_names?(inputs)

      attrs = inputs
      attrs[:latitude] = lat_long_arr[0]
      attrs[:longitude] = lat_long_arr[1]
      user = GladiatorMatch.db.create_user(attrs)

      return success(user: user)
    end

    def valid_interests?(interests)
      interests.class == Array && interests.empty? == false
    end

    def valid_names?(inputs)
      # order is important here because nil.empty? will return error
      # is this a good way to do this? - can try activesupport gem to use method blank?
      inputs[:first_name].nil? == false && inputs[:last_name].nil? == false && inputs[:first_name].empty? == false && inputs[:last_name].empty? == false
    end
  end
end