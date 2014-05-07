module GladiatorMatch
  class FindUser < UseCase
    def run(inputs)
      lat_long_arr = Geocoder.coordinates(inputs[:location])
      # binding.pry
      return failure(:invalid_location) if lat_long_arr.nil?
    end
  end
end