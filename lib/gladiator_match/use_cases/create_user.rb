module GladiatorMatch
  class CreateUser < UseCase
    def run(inputs)
      return failure(:invalid_login) if inputs[:github_login].empty?
      return failure(:invalid_interest) if !valid_interests?(inputs[:interests])
      success()
      # return failure(:invalid_location) if Geocoder.coordinates(inputs[:location]).nil?
      return failure(:invalid_name) if !valid_names?(inputs)
    end

    def valid_interests?(interests)
      interests.class == Array && interests.empty? == false
    end

    def valid_names?(inputs)
      # order is important here because nil.empty? will return error
      # is this a good way to do this?
      inputs[:first_name].nil? == false && inputs[:lastname] == false && inputs[:first_name].empty? == false && inputs[:last_name].empty? == false
    end
  end
end