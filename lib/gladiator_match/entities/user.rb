# include Geocoder::Model::Mongoid

module GladiatorMatch
  class User < Entity
    attr_accessor :id, :first_name, :last_name, :github_login, :email
    # not invidually tested in db spec
    attr_accessor :location, :remote, :latitude, :longitude, :password, :github_id
    # user has many of these:
    attr_accessor :interests, :groups

    # geocoded_by :latitude, :longitude

    def intialize(attrs)
      @github_login = ''
      @interests = []
      @remote = false
      super(attrs)
    end
  end
end

