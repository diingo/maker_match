module GladiatorMatch
  class LogIn < UseCase
    def run(inputs)
      return failure(:invalid_login) if inputs[:github_login].blank?

      session_key = GladiatorMatch.db.create_session

      success(session_key: session_key)
    end
  end
end