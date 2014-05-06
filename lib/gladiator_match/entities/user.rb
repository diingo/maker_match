module GladiatorMatch
  class User < Entity
    attr_accessor :id, :first_name, :last_name, :github_login, :email
    # not invidually tested in db spec
    attr_accessor :location, :remote, :latitude, :longitude
    # user has many of these:
    attr_accessor :interests, :groups

    def intialize(attrs)
      @github_login = ''
      @interests = []
      @remote = false
      super(attrs)
    end
  end
end

