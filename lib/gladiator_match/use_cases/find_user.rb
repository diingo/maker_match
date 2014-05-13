module GladiatorMatch
  class FindUser < UseCase
    def run(inputs)
      lat_long_arr = Geocoder.coordinates(inputs[:location])
      # binding.pry
      return failure(:invalid_location) if lat_long_arr.nil?
      return failure(:invalid_interest) if inputs[:interest].blank?
      return failure(:no_user_with_that_interest)
    end
  end
end