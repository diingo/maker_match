# include Geocoder::Model::Mongoid

module GladiatorMatch
  class User < Entity
    attr_accessor :id, :first_name, :last_name, :github_login, :email
    attr_accessor :location, :remote, :latitude, :longitude, :password, :github_id
    # extras for date
    attr_accessor :created_at, :updated_at
    # user has many of these:
    attr_accessor :interests, :groups

    # geocoded_by :latitude, :longitude

    def initialize(attrs)
      @github_login = ''
      @interests = []
      @remote = false
      super(attrs)
    end
  end
end

