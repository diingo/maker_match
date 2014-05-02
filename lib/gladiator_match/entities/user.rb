module GladiatorMatch
  class User < Entity
    attr_accessor :id, :first_name, :last_name, :github_login, :email, :groups
  end
end