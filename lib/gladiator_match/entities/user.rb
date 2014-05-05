module GladiatorMatch
  class User < Entity
    attr_accessor :id, :first_name, :last_name, :github_login, :email, :groups 
    attr_accessor :interests, :location, :remote

    def intialize(attrs)
      @github_login = ''
      @interests = []
      super(attrs)
    end
  end
end

