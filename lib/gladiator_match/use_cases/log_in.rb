module GladiatorMatch
  class LogIn < UseCase
    def run(inputs)
      return failure(:invalid_login) if inputs[:github_login].blank?

      if GladiatorMatch.db.get_user_by_login(inputs[:github_login]).nil?
        user = GladiatorMatch.db.create_user(github_login: inputs[:github_login])
      else
        user = GladiatorMatch.db.get_user_by_login(inputs[:github_login])
      end

      session_key = GladiatorMatch.db.create_session(user_id: user.id)

      success(session_key: session_key, user: user)
    end
  end
end